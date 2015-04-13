module Main where

import Rainbox.Core
import Rainbox.Instances ()
import Rainbow.Types
import Test.Tasty
import Test.Tasty.QuickCheck
import Data.Sequence (Seq, viewl, ViewL(..))
import qualified Data.Sequence as Seq
import qualified Data.Foldable as F
import qualified Data.Text as X
import Control.Monad

main :: IO ()
main = defaultMain . testGroup "Rainbox tests" $
  [ testGroup "split" $
    [ testProperty "sum is equal to original number" $ \a ->
      let (x, y) = split a
      in x + y == a
    ]

  , testGroup "intersperse" $
    [ testProperty "makes no change to empty Seq" $
      intersperse undefined Seq.empty == (Seq.empty :: Seq ())

    , testProperty "makes no change to singleton Seq" $
      intersperse undefined (Seq.singleton ()) == Seq.singleton ()

    , testProperty "lengthens other Seq by length - 1" $ \i ->
      i > 1 ==>
      Seq.length (intersperse undefined (Seq.replicate i ())) ==
      i + (i - 1)
    ]

  , testGroup "HasHeight" $
    [ testGroup "never returns less than zero" $
      let go a = let h = height a in classify (h > 2) "h > 2" (h >= 0) in
      [ testProperty "RodRows" $
          \a -> go (a `asTypeOf` (undefined :: RodRows))
      , testProperty "Core" $
          \a -> go (a `asTypeOf` (undefined :: Core))
      , testProperty "Box Vertical" $
          \a -> go (a `asTypeOf` (undefined :: Box Vertical))
      , testProperty "Box Horizontal" $
          \a -> go (a `asTypeOf` (undefined :: Box Horizontal))
      , testProperty "Payload Vertical" $
          \a -> go (a `asTypeOf` (undefined :: Payload Vertical))
      , testProperty "Payload Horizontal" $
          \a -> go (a `asTypeOf` (undefined :: Payload Horizontal))
      ]
    ]

  , testGroup "HasWidth" $
    [ testGroup "never returns less than zero" $
      let go a = let w = width a in classify (w > 2) "w > 2" (w >= 0) in
      [ testProperty "Chunk" $
          \a -> go (a `asTypeOf` (undefined :: Chunk))
      , testProperty "RodRows" $
          \a -> go (a `asTypeOf` (undefined :: RodRows))
      , testProperty "Rod" $
          \a -> go (a `asTypeOf` (undefined :: Rod))
      , testProperty "Core" $
          \a -> go (a `asTypeOf` (undefined :: Core))
      , testProperty "Box Vertical" $
          \a -> go (a `asTypeOf` (undefined :: Box Vertical))
      , testProperty "Box Horizontal" $
          \a -> go (a `asTypeOf` (undefined :: Box Horizontal))
      , testProperty "Payload Vertical" $
          \a -> go (a `asTypeOf` (undefined :: Payload Vertical))
      , testProperty "Payload Horizontal" $
          \a -> go (a `asTypeOf` (undefined :: Payload Horizontal))
      ]
    ]

  , testGroup "chunk" $
    [ testProperty "height is always 1" $ \c ->
      let _types = c :: Chunk in height c == 1
    , testProperty "width is sum of number of characters" $ \c@(Chunk _ t) ->
      width c == F.sum (fmap X.length t)
    ]

  , testGroup "addVerticalPadding"
    [ testProperty "all RodRows same height" allRodRowsSameHeight
    ]

  ]

allRodRowsSameHeight :: Seq RodRows -> Bool
allRodRowsSameHeight sqnce = case viewl sqnce of
  EmptyL -> True
  x :< xs -> F.all (== height x) . fmap height $ xs

allRodRowsSameWidth :: Seq RodRows -> Bool
allRodRowsSameWidth sqnce = case viewl sqnce of
  EmptyL -> True
  x :< _ -> F.all (== height1) . join . fmap toLengths $ sqnce
    where
      height1 = case x of
        RodRowsNoHeight w -> w
        RodRowsWithHeight sqn -> case viewl sqn of
          EmptyL -> 0
          y :< _ -> F.sum . fmap width $ y
      toLengths (RodRowsNoHeight w) = Seq.singleton w
      toLengths (RodRowsWithHeight sq) = fmap (F.sum . fmap width) sq
