{-# OPTIONS_GHC -Wall #-}

module Main where

import Data.Binary
import Distribution.PackageDescription
import Distribution.Simple
import Distribution.Simple.InstallDirs hiding (absoluteInstallDirs)
import Distribution.Simple.LocalBuildInfo
import System.Exit
import System.FilePath
import System.Process

main :: IO ()
main =
    defaultMainWithHooks
        simpleUserHooks
        { postConf =
              \args flags pkg_descr lbi -> do
                  encodeFile
                      biPath
                      emptyBuildInfo
                      { cppOptions =
                            [ "-DDATADIR=" ++
                              show
                                  (datadir $
                                   absoluteInstallDirs pkg_descr lbi NoCopyDest)
                            ]
                      }
                  postConf simpleUserHooks args flags pkg_descr lbi
        , preBuild = preAny
        , preRepl = preAny
        , preHaddock = preAny
        , postCopy =
              \args copy_flags pkg_descr lbi -> do
                  let nodedir =
                          datadir (absoluteInstallDirs pkg_descr lbi NoCopyDest) </>
                          "escodegen-server"
                  withCreateProcess ((shell "npm install") {cwd = Just nodedir}) $ \_ _ _ h -> do
                      r <- waitForProcess h
                      case r of
                          ExitSuccess -> pure ()
                          ExitFailure x ->
                              fail $
                              "npm install failed with exit code " ++ show x
                  postCopy simpleUserHooks args copy_flags pkg_descr lbi
        }
  where
    biPath = "escodegen.buildinfo"
    preAny _ _ = do
        bi <- decodeFile biPath
        pure (Just bi, [])
