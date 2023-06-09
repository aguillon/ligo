{- | Continuous location inside the source and utilities.
-}

module Range
  ( HasRange(..)
  , Range(..)
  , PreprocessedRange(..)
  , cutOut
  , excluding
  , intersects
  , interval
  , fromLspPosition
  , fromLspPositionUri
  , fromLspRange
  , fromLspRangeUri
  , merged
  , point
  , toLspRange

    -- * Lenses
  , rStart
  , rFinish
  , rFile
  , rangeLines
  , startLine
  , finishLine
  )
  where

import Language.LSP.Types qualified as LSP

import Control.Lens (makeLenses)
import Data.ByteString qualified as BS

import Duplo.Lattice
import Duplo.Pretty

point :: LSP.UInt -> LSP.UInt -> Range
point l c = Range (l, c, 0) (l, c, 0) ""

-- | Construct a range spanning a single line `line` from a column
-- `colSt` (inclusively) to `colFin` (exclusively).
interval :: LSP.UInt -> LSP.UInt -> LSP.UInt -> Range
interval line colSt colFin = Range (line, colSt, 0) (line, colFin, 0) ""

-- | A continuous location in text. This includes information to the file as
-- seen by the user (i.e.: before preprocessing).
data Range = Range
  { _rStart  :: (LSP.UInt, LSP.UInt, LSP.UInt)  -- ^ [Start: line, col, byte-offset...
  , _rFinish :: (LSP.UInt, LSP.UInt, LSP.UInt)  -- ^ ... End: line, col, byte-offset).
  , _rFile   :: FilePath
  }
  deriving (Show) via PP Range

rangeLines :: Traversal' Range LSP.UInt
rangeLines f (Range (sl, sc, so) (fl, fc, fo) file) =
  Range
    <$> ((,,) <$> f sl <*> pure sc <*> pure so)
    <*> ((,,) <$> f fl <*> pure fc <*> pure fo)
    <*> pure file

-- @UInt" is a newtype over @Int#@, so it can be converted to/from `Int` safely
type instance IntBaseType LSP.UInt = IntBaseType Int

instance Pretty Range where
  pp (Range (ll, lc, _) (rl, rc, _) f) =
    text f <.> "@"
    <.> int (fromIntegral @LSP.UInt @Int ll) <.> ":"
    <.> int (fromIntegral @LSP.UInt @Int lc) <.> "-"
    <.> int (fromIntegral @LSP.UInt @Int rl) <.> ":"
    <.> int (fromIntegral @LSP.UInt @Int rc)

-- | Like 'Range', but includes information on the preprocessed range of the
-- file.
newtype PreprocessedRange
  = PreprocessedRange Range
  deriving newtype (Eq, Lattice, Ord, Pretty, Show)

-- | Ability to get range out of something.
class HasRange a where
  getRange :: a -> Range

instance HasRange Range where
  getRange = id

-- | Convert `squirrel` range to `haskell-lsp` range.
-- Note that we consider the first line to be at position 1.
toLspRange :: Range -> LSP.Range
toLspRange Range
  { _rStart  = (rsl, rsc, _)
  , _rFinish = (rfl, rfc, _)
  } = LSP.Range
  { LSP._start = LSP.Position{ LSP._line = rsl - 1, LSP._character = rsc - 1 }
  , LSP._end   = LSP.Position{ LSP._line = rfl - 1, LSP._character = rfc - 1 }
  }

fromLspPosition :: LSP.Position -> Range
fromLspPosition (LSP.Position l c) = point (l + 1) (c + 1)

fromLspPositionUri :: LSP.Position -> LSP.Uri -> Range
fromLspPositionUri position uri = (fromLspPosition position) {_rFile = fromMaybe "" $ LSP.uriToFilePath uri}

fromLspRange :: LSP.Range -> Range
fromLspRange
  (LSP.Range
    (fromLspPosition -> s)
    (fromLspPosition -> e)) = merged s e

fromLspRangeUri :: LSP.Range -> LSP.Uri -> Range
fromLspRangeUri
  (LSP.Range
    (fromLspPosition -> s)
    (fromLspPosition -> e)) uri = (merged s e) {_rFile = fromMaybe "" $ LSP.uriToFilePath uri}

-- | Extract textual representation of given range.
cutOut :: Range -> ByteString -> Text
cutOut (Range (_, _, s) (_, _, f) _) bs =
  decodeUtf8
    $ BS.take (fromIntegral (f - s))
    $ BS.drop (fromIntegral  s)
      bs

excluding :: Range -> Range -> Range
excluding (Range _ s _) (Range _ f t) = Range s f t

merged :: Range -> Range -> Range
merged (Range s _ _) (Range _ f t) = Range s f t

-- | Returns whether the two ranges have some common intersection. Ranges in
-- different files are always considered to not have intersections.
--
-- N.B.: If R1 = [(l1, c1) ... (l2, c2)] and R2 = [(l2, c2) ... (l3, c3)], this
-- function will return 'False'. That is, a single point of intersection is not
-- enough for both of them to be considered equal, since ranges are exclusive in
-- their end points.
intersects :: Range -> Range -> Bool
intersects (Range (ll1, lc1, _) (ll2, lc2, _) lf) (Range (rl1, rc1, _) (rl2, rc2, _) rf)
  -- Different files never intersect.
  | lf /= rf = False
  -- If l's start is before or at r's start, it intersects iff its end is after
  -- r's start (but not at, see function's N.B. part).
  | ll1 < rl1 || ll1 == rl1 && lc1 <= rc1 = ll2 > rl1 || ll2 == rl1 && lc2 > rc1
  -- Same as before, but with l and r swapped.
  | rl1 < ll1 || rl1 == ll1 && rc1 <= lc1 = rl2 > ll1 || rl2 == ll1 && rc2 > lc1
  -- Otherwise, the ranges are disjoint.
  | otherwise = False

-- | Inclusion order
instance Lattice Range where
  Range (ll1, lc1, _) (ll2, lc2, _) _
    `leq` Range (rl1, rc1, _) (rl2, rc2, _) _ =
    (rl1 < ll1 || rl1 == ll1 && rc1 <= lc1) &&
    (rl2 > ll2 || rl2 == ll2 && rc2 >= lc2)

instance Eq Range where
  Range (l, c, _) (r, d, _) f == Range (l1, c1, _) (r1, d1, _) f1 =
    (l, c, r, d, f) == (l1, c1, r1, d1, f1)

-- | Lexicographic order
instance Ord Range where
  Range (l, c, _) (r, d, _) f `compare` Range (l1, c1, _) (r1, d1, _) f1 =
    compare l l1 <> compare c c1 <> compare r r1 <> compare d d1 <> compare f f1

makeLenses ''Range

startLine :: Lens' Range LSP.UInt
startLine = rStart . _1
{-# INLINE startLine #-}

finishLine :: Lens' Range LSP.UInt
finishLine = rFinish . _1
{-# INLINE finishLine #-}
