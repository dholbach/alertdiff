module AlertDiff.Config
    ( Options(..),
      optionParser
    ) where

import Data.List.Split     (splitOn)
import Data.Semigroup      ((<>))
import Options.Applicative (Parser,ReadM,ParserInfo,long,option,value,info,(<**>),fullDesc,strOption,optional,maybeReader,helper,auto,showDefault)
import Data.Set            (Set)
import qualified Data.Set  as Set

-- | Runtime configuration
data Options =
    Options { port              :: Int          -- ^ Port on which to serve API
            , expectedURL       :: Maybe String -- ^ AlertManager from which to pull expected alerts
            , actualURL         :: Maybe String -- ^ AlertManager from which to pull actual alerts
            , expectedTokenFile :: Maybe String -- ^ Authentication token for pulling expected alerts
            , actualTokenFile   :: Maybe String -- ^ Authentication token for pulling actual alerts
            , excludedAlarms    :: Set String   -- ^ Names of alerts which should be excluded from comparison
            , excludedLabels    :: Set String   -- ^ Names of labels which should be excluded from comparison
            }

stringSet :: ReadM (Set String)
stringSet = maybeReader f
    where f s = Just $ Set.fromList $ splitOn "," s

argParser :: Parser Options
argParser = Options
    <$> option auto (long "port" <> value 80 <> showDefault)
    <*> optional (strOption (long "expected-url"))
    <*> optional (strOption (long "actual-url"))
    <*> optional (strOption (long "expected-token-file"))
    <*> optional (strOption (long "actual-token-file"))
    <*> option stringSet (long "excluded-alerts" <> value Set.empty)
    <*> option stringSet (long "excluded-labels" <> value Set.empty)

-- | Options parser yielding a runtime configuration from command line arguments
optionParser :: ParserInfo Options
optionParser = info (argParser <**> helper) fullDesc
