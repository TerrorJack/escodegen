{-# OPTIONS_GHC -Wall #-}

module Main where

import Data.Binary
import Distribution.PackageDescription
import Distribution.Simple
import Distribution.Simple.InstallDirs hiding (absoluteInstallDirs)
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Program
import Distribution.Verbosity
import System.FilePath

main :: IO ()
main =
    defaultMainWithHooks
        simpleUserHooks
        { hookedPrograms = npm : hookedPrograms simpleUserHooks
        , postConf =
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
                  runDbProgram
                      verbose
                      npm
                      (withPrograms lbi)
                      ["install", "--prefix", nodedir]
                  postCopy simpleUserHooks args copy_flags pkg_descr lbi
        }
  where
    biPath = "escodegen.buildinfo"
    preAny _ _ = do
        bi <- decodeFile biPath
        pure (Just bi, [])
    npm = simpleProgram "npm"
