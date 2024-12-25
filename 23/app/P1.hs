module Main where

import Data.List.Split
import qualified Data.List as List
import qualified Data.Map as Map
import qualified Data.Maybe as Maybe
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.Environment
import System.Exit
import Data.List (isPrefixOf)

-- main :: IO()
main = do
    argv <- getArgs
    if null argv then do
        print "No file included!"
        exitFailure
    else
        run $ head argv

run fp = do
    pairDecls <- T.unpack <$> TIO.readFile fp
    runStr pairDecls

runStr pairDecls =
    let pairs = map (pairListToTuple . splitOn "-") $ lines pairDecls
        -- map of a to set of computers b that it is connected to
        connections = foldl pairsToConnections Map.empty pairs
        tComputers = List.filter ("t" `isPrefixOf`) $ Map.keys connections
        tNetworks = foldl Set.union Set.empty $ List.map (trianglesIncluding connections) tComputers
        length = Set.size tNetworks
    in do print length

pairsToConnections acc (a, b) =
    addToConnections (addToConnections acc a b) b a

addToConnections acc a b =
    case Map.lookup a acc of
        Nothing -> Map.insert a (Set.fromList [b]) acc
        Just s -> Map.insert a (Set.insert b s) acc

pairListToTuple [x, y] = (x, y)

trianglesIncluding connections a =
    let neighbours = unwrap $ Map.lookup a connections
        pairsOfBC = Set.cartesianProduct neighbours neighbours
        validBC = Set.filter
            (\(b, c) ->
                (a /= b)
                && (a /= c)
                && (b /= c)
                && Set.member c (unwrap $ Map.lookup b connections)
            )
            pairsOfBC
    in Set.map (\(b, c) -> List.sort [a, b, c]) validBC

unwrap = Maybe.fromMaybe Set.empty