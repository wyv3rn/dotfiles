import System.Exit
import System.Process
import System.Directory
import System.IO
import System.IO.Error
import Data.List
import Data.Maybe
import Control.Monad
import Control.Exception

data Alias = Alias { alias :: String
                   , name :: String
                   , mail :: String
                   } deriving (Show, Eq, Ord)

aliasFromMuttStr :: String -> Maybe Alias
aliasFromMuttStr = aliasFromTokens . words

aliasFromTokens :: [String] -> Maybe Alias
aliasFromTokens [] = Nothing
aliasFromTokens (keyword:tokens) =
    if length tokens < 3 || keyword /= "alias" then Nothing
    else
        let
            (alias:nameAndMail) = tokens
            name = unwords . init $ nameAndMail
            mail = last nameAndMail
        in
            if isPrefixOf "<" mail && isSuffixOf ">" mail then
                Just (Alias alias name mail)
            else
                Nothing

aliasToMuttStr :: Alias -> String
aliasToMuttStr (Alias a f m) = "alias " ++ a ++ " " ++ f ++ " " ++ m

filterEmptyLines :: [String] -> [String]
filterEmptyLines = filter (\line -> not $ null line)

resolveConflicts :: [Alias] -> IO ([Alias])
resolveConflicts [] = return []
resolveConflicts [a] = return [a]
resolveConflicts (a:b:as) =
    if alias a /= alias b then do
        fmap (a:) $ resolveConflicts (b:as)
    else do
        resolved <- resolveOne a b
        case resolved of
            Just r  -> resolveConflicts (r:as)
            Nothing -> resolveConflicts as

resolveOne :: Alias -> Alias -> IO (Maybe Alias)
resolveOne a b = do
    choice <- queryUser a b
    case choice of
        'q' -> exitWith (ExitFailure 1)
        '1' -> return $ Just a
        '2' -> return $ Just b
        'm' -> do
            line <- getLine
            let maybeNew =
                    aliasFromMuttStr $ "alias " ++ alias a ++ " " ++ line
            case maybeNew of
                Just _ -> return maybeNew
                Nothing -> do
                    putStrLn "No valid input given"
                    resolveOne a b

        'd' -> return Nothing
        _   -> do
            putStrLn $ "Invalid choice (" ++ show choice ++ "), try again"
            resolveOne a b

queryUser :: Alias -> Alias -> IO Char
queryUser a b = do
    putStrLn $ "Conflict detected"
    putStrLn $ "(1) " ++ aliasToMuttStr a
    putStrLn $ "(2) " ++ aliasToMuttStr b
    putStrLn $ "(m) Enter full name and address manually after the m"
    putStrLn $ "(d) Delete both"
    putStrLn $ "(q) Abort the sync completely"
    putStrLn $ "Select resolve strategy and press enter"
    getChar

handleLocalError :: IOError -> IO String
handleLocalError e =
    if isDoesNotExistError e then do
        putStrLn "[WARN] Local file did not exist"
        return ""
    else ioError e

main = do
    let localUserPath = "/.neomutt/aliases.rc"
    let host = "alpha"
    let remotePath = ".neomutt/aliases.rc"
    let remoteBackupPath = remotePath ++ ".bak"
    (_, Just hout, _, _) <-
        createProcess (shell $ "ssh " ++ host ++ " cat " ++ remotePath) {
            std_out = CreatePipe
        }

    remoteList <- fmap (filterEmptyLines . lines) $ hGetContents hout
    localPath <- fmap (++ localUserPath) getHomeDirectory
    let localBackupPath = localPath ++ ".bak"
    localContent <- (readFile localPath) `catch` handleLocalError
    let localList = filterEmptyLines . lines $ localContent

    let combinedList = nub . sort $ remoteList ++ localList
    let aliases = catMaybes $ map aliasFromMuttStr combinedList

    let l = length combinedList
        l' = length aliases
    when (l' < l) $ do
        putStrLn $ "[WARN] Deleting " ++ show (l - l') ++ " lines"
                    ++ " that did not contain valid aliases"

    mergedLines <- fmap (map aliasToMuttStr) $ resolveConflicts aliases
    mapM putStrLn mergedLines

    when (not . null $ localList) $ do
        copyFile localPath localBackupPath
    writeFile localPath $ unlines mergedLines

    callCommand $
        "ssh " ++ host ++ " cp " ++ remotePath ++ " " ++ remoteBackupPath
    callCommand $ "scp " ++ localPath ++ " " ++ host ++ ":" ++ remotePath

    hClose hout
