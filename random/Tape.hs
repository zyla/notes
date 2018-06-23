{-# LANGUAGE NamedFieldPuns #-}

module Tape where

{-|

A 'Tape' is an equivalence class on lists under the following equivalence relation:

R(xs, ys) <=> exists n. rotate n xs = ys

In other words, a Tape represents all rotations of a particular list.

Another way to look at it:
Starting from a list:
- a multiset forgets the order of elements
- a set forgets the order and multiplicity of elements
- a tape remembers order and multiplicity, but forgets where the list starts

-}
newtype Tape a = Tape [a]

rotate :: Int -> [a] -> [a]
rotate _ [] = []
rotate 0 xs = xs
rotate n (x:xs) = rotate (n - 1) (xs ++ [x])

allRotations :: [a] -> [[a]]
allRotations [] = [[]]
allRotations xs = [rotate n xs | n <- [0..length xs-1]]

fromList :: [a] -> Tape a
fromList = Tape

instance Eq a => Eq (Tape a) where
  Tape xs == Tape ys = xs `elem` allRotations ys

smallest :: Ord a => Tape a -> [a]
smallest (Tape xs) = minimum (allRotations xs)

instance Show a => Show (Tape a) where
  show (Tape xs) = "fromList " ++ show xs

{-

Concatenation of Tapes doesn't make sense. Since we don't care where the list starts,
there's no distinguished point where two list can be glued together.

More formally, for an operation (<>), we'd like the following to hold:

forall n m xs ys. fromList xs <> fromList ys = fromList (rotate n xs) <> fromList (rotate m ys)

-}

{-
Maybe convolution makes sense?
-}

data Ring a = Ring
  { zero :: a
  , plus :: a -> a -> a
  , one :: a
  , mul :: a -> a -> a
  }

convolveWith :: Ring a -> Tape a -> Tape a -> Tape a
convolveWith Ring{zero,plus,one,mul} (Tape xs) (Tape ys) =
  _

numRing :: Num a => Ring a
numRing = Ring
  { zero = 0
  , plus = (+)
  , one = 1
  , mul = (*)
  }

convolve :: Num a => Tape a -> Tape a -> Tape a
convolve = convolveWith numRing
