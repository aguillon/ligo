{- | /The/ scope resolution system.
-}

module AST.Scope
  ( module M
  , addShallowScopes
  )
  where

import Algebra.Graph.AdjacencyMap qualified as G (vertex, vertexList)
import Control.Monad ((<=<))
import Control.Monad.IO.Unlift (MonadUnliftIO)

import AST.Includes (insertPreprocessorRanges)
import AST.Scope.Common as M
import AST.Scope.Fallback as M
import AST.Scope.FromCompiler as M
import AST.Scope.Standard as M

import Progress (ProgressCallback)

-- | Like 'addScopes', but doesn't visit includes. That is, this function only
-- sees the scopes for the given contract, and doesn't try to visit includes.
addShallowScopes
  :: forall parser m
   . (HasScopeForest parser m, MonadUnliftIO m)
  => ProgressCallback m
  -> ContractInfo
  -> m ContractInfo'
addShallowScopes reportProgress =
  (fmap (head . G.vertexList) . addScopes @parser reportProgress . G.vertex)
  <=< insertPreprocessorRanges
