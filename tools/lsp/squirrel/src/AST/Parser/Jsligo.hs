-- | Parser for a Jsligo contract.
module AST.Parser.Jsligo
  ( recognise
  ) where

import AST.Skeleton

import Duplo.Tree

import ParseTree
import Parser

recognise :: SomeRawTree -> ParserM (SomeLIGO Info)
recognise (SomeRawTree dialect rawTree)
  = fmap (SomeLIGO dialect)
  $ flip (descent (error "Jsligo.recognise")) rawTree
  $ map usingScope
  [ -- Contract
    Descent do
      boilerplate $ \case
        "source_file" -> RawContract <$> fields "toplevel"
        _ -> fallthrough

    -- Expr
  , Descent do
      boilerplate $ \case
        "unary_call"        -> UnOp       <$> field  "negate"      <*> field    "arg"
        "binary_call"       -> BinOp      <$> field  "left"        <*> field    "op"       <*> field "right"
        "apply"             -> Apply      <$> field  "function"    <*> fields   "argument"
        "block_statement"   -> Seq        <$> fields "statement"
        "list"              -> List       <$> fields "element"
        "annot_expr"        -> Annot      <$> field  "subject"     <*> field    "type"
        "if_else_statement" -> If         <$> field  "selector"    <*> field    "then"     <*> fieldOpt "else"
        "if_statement"      -> If         <$> field  "selector"    <*> field    "then"
        "record"            -> Record     <$> fields "assignment"
        "record_update"     -> RecordUpd  <$> field  "subject"     <*> fields   "field"
        "paren_expr"        -> Paren      <$> field  "expr"
        "tuple"             -> Tuple      <$> fields "item"

        "lambda"            -> Lambda     <$> fields "argument"    <*> fieldOpt "type"     <*> field "body"
        "michelson_interop" -> Michelson  <$> field  "code"        <*> field    "type"     <*> []

        "switch_case"       -> Case       <$> field  "subject"     <*> fields   "alt"
        -- TODO: add support for switch-case-default
        -- TODO: add support of loops - for & while
        -- TODO: add support for assignment & assignment operators ?? will this be handled in binop ??
        _                   -> fallthrough

    -- Pattern --
  , Descent do
      boilerplate $ \case
        "tuple_pattern"          -> IsTuple  <$> fields "pattern"
        "annot_pattern"          -> IsAnnot  <$> field  "subject"     <*> field "type"
        "list_pattern"           -> IsList   <$> fields "pattern"
        "var_pattern"            -> IsVar    <$> field  "var"
        "constr_pattern"         -> IsConstr <$> field  "constructor" <*> fieldOpt "arg"
        "spread_pattern"         -> IsSpread <$> field  "expr"
        "record_pattern"         -> IsRecord <$> fields "field"
        "paren_pattern"          -> IsParen  <$> field  "pattern"
        "wildcard"               -> return IsWildcard
        _                        -> fallthrough

    -- Irrefutable tuple --
  , Descent do
      boilerplate $ \case
        "irrefutable_tuple" -> IsTuple <$> fields "item"
        _                   -> fallthrough

    -- RecordFieldPattern -- 
  , Descent do
      boilerplate $ \case
        "record_field_pattern"   -> IsRecordField   <$> field "name" <*> field "body"
        "record_capture_pattern" -> IsRecordCapture <$> field "name"
        _                        -> fallthrough

    -- Alt --
  , Descent do
      boilerplate $ \case
        "alt"  -> Alt <$> field "pattern" <*> field "expr"
        _      -> fallthrough

    -- Record fields
  , Descent do
      boilerplate $ \case
        "capture"           -> Capture         <$> fields "accessor"
        "record_field"      -> FieldAssignment <$> fields "accessor" <*> field "value"
        "spread"            -> Spread          <$> field  "name"
        _                   -> fallthrough

    -- Preprocessor
  , Descent do
      boilerplate \case
        "preprocessor" -> Preprocessor <$> field "preprocessor_command"
        _              -> fallthrough

    -- ProcessorCommand
  , Descent do
      boilerplate' \case
        ("p_if"      , rest) -> return $ PreprocessorCommand $ "#if "      <> rest
        ("p_error"   , rest) -> return $ PreprocessorCommand $ "#error "   <> rest
        ("p_define"  , rest) -> return $ PreprocessorCommand $ "#define "  <> rest
        _                    -> fallthrough

  , Descent do
      boilerplate' $ \case
        ("||", _)     -> return $ Op "||"
        ("&&", _)     -> return $ Op "&&"
        ("<", _)      -> return $ Op "<"
        ("<=", _)     -> return $ Op "<="
        (">", _)      -> return $ Op ">"
        (">=", _)     -> return $ Op ">="
        ("==", _)     -> return $ Op "=="
        ("!=", _)     -> return $ Op "!="
        ("+", _)      -> return $ Op "+"
        ("-", _)      -> return $ Op "-"
        ("*", _)      -> return $ Op "*"
        ("/", _)      -> return $ Op "/"
        ("%", _)      -> return $ Op "%"
        ("=", _)      -> return $ Op "="
        ("*=", _)     -> return $ Op "*="
        ("/=", _)     -> return $ Op "/="
        ("%=", _)     -> return $ Op "%="
        ("+=", _)     -> return $ Op "+="
        ("-=", _)     -> return $ Op "-="
        ("negate", n) -> return $ Op n
        _             -> fallthrough

  , Descent do
      boilerplate $ \case
        "data_projection" -> QualifiedName <$> field "expr" <*> fields "accessor"
        _                 -> fallthrough

    -- Literal
  , Descent do
      boilerplate' $ \case
        ("Int",    i) -> return $ Int i
        ("Nat",    i) -> return $ Nat i
        ("Bytes",  i) -> return $ Bytes i
        ("String", i) -> return $ String i
        ("Tez",    i) -> return $ Tez i
        _             -> fallthrough

    -- Declaration
  , Descent do
      boilerplate $ \case
        "let_decl"            -> BConst       <$> field "binding"    <*> fieldOpt "type"   <*> fieldOpt "value"
        "const_decl"          -> BConst       <$> field "binding"    <*> fieldOpt "type"   <*> fieldOpt "value"
        "type_decl"           -> BTypeDecl    <$> field "type_name"  <*> fieldOpt "params" <*> field "type_value"
        "p_include"           -> BInclude     <$> field "filename"
        "p_import"            -> BImport      <$> field "filename"   <*> field "alias"
        "fun_arg"             -> BParameter   <$> field "argument"   <*> fieldOpt "type"
        "namespace_statement" -> BModuleDecl  <$> field "moduleName" <*> fields "declaration"
        "import_statement"    -> BModuleAlias <$> field "moduleName" <*> fields "module"
        _                     -> fallthrough

    -- TypeParams
  , Descent do
      boilerplate \case
        "type_params" -> TypeParams <$> fields "param"
        _             -> fallthrough

    -- MichelsonCode
  , Descent do
      boilerplate' \case
        ("michelson_code", code) -> return $ MichelsonCode code
        _                        -> fallthrough

    -- Name
  , Descent do
      boilerplate' $ \case
        ("Name", n) -> return $ Name n
        _           -> fallthrough

    -- NameDecl
  , Descent do
      boilerplate' $ \case
        ("NameDecl", n) -> return $ NameDecl n
        _               -> fallthrough

    -- ModuleName
  , Descent do
      boilerplate' $ \case
        ("ModuleName", n) -> return $ ModuleName n
        _                 -> fallthrough

    -- Type
  , Descent do
      boilerplate $ \case
        "string_type"      -> TString  <$> field  "value"
        "fun_type"         -> TArrow   <$> field  "domain"  <*> field "codomain"
        "app_type"         -> TApply   <$> field  "functor" <*> fields "argument"
        "record_type"      -> TRecord  <$> fields "field"
        "tuple_type"       -> TProduct <$> fields "element"
        "sum_type"         -> TSum     <$> fields "variant"
        "TypeWildcard"     -> pure TWildcard
        "var_type"         -> TVariable <$> field "name"
        _                  -> fallthrough

    -- Module access:
  , Descent do
      boilerplate $ \case
        "module_access_t" -> ModuleAccess <$> fields "path" <*> field "type"
        "module_access"   -> ModuleAccess <$> fields "path" <*> field "field"
        _                 -> fallthrough

    -- Variant
  , Descent do
      boilerplate $ \case
        "variant" -> Variant <$> field "constructor" <*> fieldOpt "arguments"
        _         -> fallthrough

    -- TField
  , Descent do
      boilerplate $ \case
        "field_decl" -> TField <$> field "field_name" <*> fieldOpt "field_type"
        _            -> fallthrough

    -- TypeName
  , Descent do
      boilerplate' $ \case
        ("TypeName", name) -> return $ TypeName name
        _                  -> fallthrough

    -- TypeVariableName
  , Descent do
      boilerplate' \case
        ("TypeVariableName", name) -> pure $ TypeVariableName name
        _                          -> fallthrough

    -- FieldName
  , Descent do
      boilerplate' $ \case
        ("FieldName", name) -> return $ FieldName name
        _                   -> fallthrough

    -- Ctor
  , Descent do
      boilerplate' $ \case
        ("ConstrName", name)   -> return $ Ctor name
        ("True_kwd", _)        -> return $ Ctor "True"
        ("False_kwd", _)       -> return $ Ctor "False"
        ("Unit_kwd", _)        -> return $ Ctor "Unit"
        _                      -> fallthrough

  -- Err
  , Descent noMatch
  ]
