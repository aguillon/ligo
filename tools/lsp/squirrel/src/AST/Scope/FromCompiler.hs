{-# LANGUAGE RecordWildCards #-}

module AST.Scope.FromCompiler
  ( FromCompiler
  ) where

import Control.Category ((>>>))
import Control.Monad.IO.Unlift (MonadIO, MonadUnliftIO)
import Data.Foldable (foldrM)
import Data.Function (on)
import Data.HashMap.Strict ((!))
import Data.Map (Map)
import Data.Map qualified as Map
import Duplo.Lattice
import Duplo.Tree (make, only)
import UnliftIO.Directory (canonicalizePath)

import AST.Scope.Common
import AST.Scope.ScopedDecl (DeclarationSpecifics (..), ScopedDecl (..), ValueDeclSpecifics (..))
import AST.Scope.ScopedDecl.Parser (parseTypeDeclSpecifics)
import AST.Skeleton (Lang, SomeLIGO (..))
import Cli
import ListZipper (atLocus, find, withListZipper)
import Product
import Range
import Util.Graph (traverseAMConcurrently)

data FromCompiler

-- FIXME: If one contract throws an exception, the entire thing will fail. Standard
-- scopes will use Fallback.
instance (HasLigoClient m, MonadUnliftIO m) => HasScopeForest FromCompiler m where
  scopeForest = traverseAMConcurrently \(FindContract ast (SomeLIGO dialect _) msg) -> do
    (defs, _) <- getLigoDefinitions ast
    forest <- fromCompiler dialect defs
    pure $ FindContract ast forest msg

-- | Extract `ScopeForest` from LIGO scope dump.
fromCompiler :: forall m. MonadIO m => Lang -> LigoDefinitions -> m ScopeForest
fromCompiler dialect (LigoDefinitions decls scopes) =
    foldrM (buildTree decls) (ScopeForest [] Map.empty) scopes
  where
    -- For a new scope to be injected, grab its range and decl and start
    -- injection process.
    buildTree :: LigoDefinitionsInner -> LigoScope -> ScopeForest -> m ScopeForest
    buildTree (LigoDefinitionsInner decls') (LigoScope r es _) sf = do
      ds <- Map.fromList <$> mapM (fromLigoDecl . (decls' !)) es
      let rs = Map.keysSet ds
      r' <- normalizeRange $ fromLigoRangeOrDef r
      pure (injectScope (make (rs :> r' :> Nil, []), ds) sf)

    normalizeRange :: Range -> m Range
    normalizeRange = rFile canonicalizePath

    -- LIGO compiler provides no comments, so they left [].
    fromLigoDecl :: LigoDefinitionScope -> m (DeclRef, ScopedDecl)
    fromLigoDecl (LigoDefinitionScope n orig bodyR ty refs) = do
      r <- normalizeRange . fromLigoRangeOrDef $ orig
      rs <- mapM (normalizeRange . fromLigoRangeOrDef) refs
      let _vdsInitRange = mbFromLigoRange bodyR
          _vdsParams = Nothing
          _vdsTspec = parseTypeDeclSpecifics . fromLigoTypeFull <$> ty
          vspec = ValueDeclSpecifics{ .. }
      pure ( DeclRef n r
           , ScopedDecl n r (r : rs) [] dialect (ValueSpec vspec)
           )

    -- Find a place for a scope inside a ScopeForest.
    injectScope :: (ScopeTree, Map DeclRef ScopedDecl) -> ScopeForest -> ScopeForest
    injectScope (subject, ds') (ScopeForest forest ds) =
        ScopeForest (loop forest) (ds <> ds')
      where
        loop
          = withListZipper
          $ find (subject `isCoveredBy`) >>> atLocus maybeLoop

        isCoveredBy = leq `on` getRange

        -- If there are no trees above subject here, just put it in.
        -- Otherwise, put it in a tree that covers it.
        maybeLoop :: Maybe ScopeTree -> Maybe ScopeTree
        maybeLoop = Just . maybe subject restart

        -- Take a forest out of tree, loop, put it back.
        restart (only -> (r, trees)) = make (r, loop trees)
