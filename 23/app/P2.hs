module Main where

import Debug.Trace
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
        biggestNetwork = maximumBronKerbosch connections
        password = List.intercalate "," $ Set.toAscList biggestNetwork
    in do
        print password

pairsToConnections acc (a, b) =
    addToConnections (addToConnections acc a b) b a

addToConnections acc a b =
    case Map.lookup a acc of
        Nothing -> Map.insert a (Set.fromList [b]) acc
        Just s -> Map.insert a (Set.insert b s) acc

maximumBronKerbosch connections =
    let r = Set.empty
        p = Set.fromList $ Map.keys connections
        x = Set.empty
    in innerMaxBronKerbosch connections r p x

innerMaxBronKerbosch connections r p x =
    -- trace ("r: " ++ show r ++ " p: " ++ show p ++ " x: " ++ show x) $
    if (Set.size p == 0) && (Set.size x == 0) then
        r
    else
        let u = Set.elemAt 0 $ Set.take 1 $ Set.union p x
            nu = neighboursOf connections u
            inner (r, p, x, largestClique) v =
                let nv = neighboursOf connections v
                    newR = Set.insert v r
                    newP = Set.intersection p nv
                    newX = Set.intersection x nv
                    innerMax = innerMaxBronKerbosch connections newR newP newX
                    biggerClique = if Set.size largestClique < Set.size innerMax then
                        innerMax
                    else
                        largestClique
                in (r, Set.delete v p, Set.insert v x, biggerClique)
            pdnu = Set.difference p nu
            (_, _, _, largestClique) = foldl inner (r, p, x, Set.empty) pdnu
        in largestClique

pairListToTuple [x, y] = (x, y)

unwrap = Maybe.fromMaybe Set.empty

neighboursOf connections v =
    unwrap $ Map.lookup v connections