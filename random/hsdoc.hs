{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE LambdaCase #-}
module Main where

import Control.Monad
import Data.List
import Data.Maybe
import System.Environment
import Documentation.Haddock
import Documentation.Haddock.Types
import System.Process
import Control.Exception
import qualified Data.Map as M
import System.Exit

-- GHC
import Pretty
import Outputable
import qualified Module
import Name (Name(..))
import qualified Name

-- 1. read all iface files, make giant DocMap
-- 2. find InstalledInterface for module
-- 3. for all exports, find them in DocMap and display
-- 4. TODO: lol no types, use hoogle instead
--
-- Approaches:
--
-- 1. haddock api, directly on packages
--  - slow
--  - need to find all the packages
--
-- 2. haddock api, installed interfaces (.haddock)
--  - no types
--  - no module documentation
--  - no nice data type presentation
--
-- 3. hoogle
--  - need to convert docs from html
--  - no nice data type presentation
--  - no module documentation
--
-- 4. installed interfaces + hoogle
--  - hack
--  - still no module documentation
--
-- 5. haddock api, directly on packages, precompute

main :: IO ()
main = do
  hsdoc "Data.Maybe"

findModule :: String -> [InstalledInterface] -> Maybe InstalledInterface
findModule name = listToMaybe . filter ((==name) . instModuleName)
  where
    instModuleName = Module.moduleNameString . Module.moduleName . instMod

hsdoc moduleName = do
  ifaces <- readIfaceFiles
  let docMap = mkDocMap ifaces
  case findModule moduleName ifaces of

    Just iface -> do
      showIfaceDoc docMap iface

    Nothing -> do
      putStrLn $ "Module not found: " ++ moduleName
      exitFailure

listInterfaceFiles :: IO [FilePath]
listInterfaceFiles = parseGhcPkgDump <$> readCreateProcess (shell "ghc-pkg dump") ""

parseGhcPkgDump = concatMap extractHaddockInterfaces . map words . lines
  where
    extractHaddockInterfaces ("haddock-interfaces:" : paths) = paths
    extractHaddockInterfaces _ = []

readIfaceFiles :: IO [InstalledInterface]
readIfaceFiles = do
  interfaceFiles <- listInterfaceFiles
  concat <$> mapM readFile interfaceFiles

  where
  readFile file = do
    e_ifaces <- try $ fmap ifInstalledIfaces <$> readInterfaceFile freshNameCache file
    case e_ifaces of
      Left (err :: SomeException) -> do
        -- FIXME: some files outputted by 'ghc-pkg dump' are nonexistent (on my machine)
        -- putStrLn $ "Error reading " ++ file ++ ": " ++ show err
        pure []
      Right (Left err) -> do
        putStrLn $ "Error reading " ++ file ++ ": " ++ show err
        pure []
      Right (Right ifaces) -> pure ifaces

mkDocMap :: [InstalledInterface] -> DocMap Name.Name
mkDocMap = foldMap instDocMap

instance Show Name.Name where show = show . Name.occName
instance Show Name.OccName where show = Name.occNameString
instance Show Module.ModuleName where show = Module.moduleNameString

showIfaceDoc :: DocMap Name -> InstalledInterface -> IO ()
showIfaceDoc docMap iface = do
  let exportDocs = mapMaybe (\export -> (,) export <$> M.lookup export docMap) (instExports iface)
  putStrLn $ renderModule exportDocs

renderModule = intercalate "\n" . map renderDecl

renderDecl :: (Name, MDoc Name) -> String
renderDecl (name, MetaDoc _ doc) = show name ++ "\n" ++ renderDoc doc

renderDoc = \case
  DocEmpty           -> ""
  DocAppend x y      -> renderDoc x ++ renderDoc y
  DocString str      -> str
  DocIdentifier name -> show name
  DocParagraph doc   -> renderDoc doc ++ "\n"
  DocMonospaced doc  -> "`" ++ renderDoc doc ++ "`"
  DocBold doc        -> renderDoc doc
  DocHeader (Header _ doc) -> "\n" ++ renderDoc doc ++ "\n"
  DocExamples examples -> concatMap renderExample examples ++ "\n"
  doc -> show doc

  where
    renderExample (Example expr results) = ">>> " ++ expr ++ "\n" ++ concatMap (++"\n") results
