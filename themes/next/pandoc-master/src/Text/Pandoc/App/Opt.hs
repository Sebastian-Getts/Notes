{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE CPP                 #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE FlexibleInstances   #-}
{- |
   Module      : Text.Pandoc.App.Opt
   Copyright   : Copyright (C) 2006-2019 John MacFarlane
   License     : GNU GPL, version 2 or above

   Maintainer  : John MacFarlane <jgm@berkeley@edu>
   Stability   : alpha
   Portability : portable

Options for pandoc when used as an app.
-}
module Text.Pandoc.App.Opt (
            Opt(..)
          , LineEnding (..)
          , IpynbOutput (..)
          , defaultOpts
          ) where
import Prelude
import Data.Char (isLower, toLower)
import GHC.Generics hiding (Meta)
import Text.Pandoc.Filter (Filter (..))
import Text.Pandoc.Logging (Verbosity (WARNING))
import Text.Pandoc.Options (TopLevelDivision (TopLevelDefault),
                            TrackChanges (AcceptChanges),
                            WrapOption (WrapAuto), HTMLMathMethod (PlainMath),
                            ReferenceLocation (EndOfDocument),
                            ObfuscationMethod (NoObfuscation),
                            CiteMethod (Citeproc))
import Text.Pandoc.Shared (camelCaseToHyphenated)
import Text.DocLayout (render)
import Text.DocTemplates (Context(..), Val(..))
import Data.Text (Text, unpack)
import qualified Data.Text as T
import qualified Data.Map as M
import Text.Pandoc.Definition (Meta(..), MetaValue(..))
import Data.Aeson (defaultOptions, Options(..))
import Data.Aeson.TH (deriveJSON)
import Control.Applicative ((<|>))
import Data.YAML

-- | The type of line-endings to be used when writing plain-text.
data LineEnding = LF | CRLF | Native deriving (Show, Generic)

instance FromYAML LineEnding where
  parseYAML = withStr "LineEnding" $ \t ->
    case T.toLower t of
      "lf"     -> return LF
      "crlf"   -> return CRLF
      "native" -> return Native
      _        -> fail $ "Unknown line ending type " ++ show t

-- | How to handle output blocks in ipynb.
data IpynbOutput =
    IpynbOutputAll
  | IpynbOutputNone
  | IpynbOutputBest
  deriving (Show, Generic)

instance FromYAML IpynbOutput where
  parseYAML = withStr "LineEnding" $ \t ->
    case t of
      "none"  -> return IpynbOutputNone
      "all"   -> return IpynbOutputAll
      "best"  -> return IpynbOutputBest
      _       -> fail $ "Unknown ipynb output type " ++ show t

-- | Data structure for command line options.
data Opt = Opt
    { optTabStop               :: Int     -- ^ Number of spaces per tab
    , optPreserveTabs          :: Bool    -- ^ Preserve tabs instead of converting to spaces
    , optStandalone            :: Bool    -- ^ Include header, footer
    , optFrom                  :: Maybe String  -- ^ Reader format
    , optTo                    :: Maybe String  -- ^ Writer format
    , optTableOfContents       :: Bool    -- ^ Include table of contents
    , optShiftHeadingLevelBy   :: Int     -- ^ Shift heading level by
    , optTemplate              :: Maybe FilePath  -- ^ Custom template
    , optVariables             :: Context Text    -- ^ Template variables to set
    , optMetadata              :: Meta -- ^ Metadata fields to set
    , optMetadataFiles         :: [FilePath]  -- ^ Name of YAML metadata files
    , optOutputFile            :: Maybe FilePath  -- ^ Name of output file
    , optInputFiles            :: [FilePath] -- ^ Names of input files
    , optNumberSections        :: Bool    -- ^ Number sections in LaTeX
    , optNumberOffset          :: [Int]   -- ^ Starting number for sections
    , optSectionDivs           :: Bool    -- ^ Put sections in div tags in HTML
    , optIncremental           :: Bool    -- ^ Use incremental lists in Slidy/Slideous/S5
    , optSelfContained         :: Bool    -- ^ Make HTML accessible offline
    , optHtmlQTags             :: Bool    -- ^ Use <q> tags in HTML
    , optHighlightStyle        :: Maybe String -- ^ Style to use for highlighted code
    , optSyntaxDefinitions     :: [FilePath]  -- ^ xml syntax defs to load
    , optTopLevelDivision      :: TopLevelDivision -- ^ Type of the top-level divisions
    , optHTMLMathMethod        :: HTMLMathMethod -- ^ Method to print HTML math
    , optAbbreviations         :: Maybe FilePath -- ^ Path to abbrevs file
    , optReferenceDoc          :: Maybe FilePath -- ^ Path of reference doc
    , optEpubSubdirectory      :: String -- ^ EPUB subdir in OCF container
    , optEpubMetadata          :: Maybe FilePath   -- ^ EPUB metadata
    , optEpubFonts             :: [FilePath] -- ^ EPUB fonts to embed
    , optEpubChapterLevel      :: Int     -- ^ Header level at which to split chapters
    , optEpubCoverImage        :: Maybe FilePath -- ^ Cover image for epub
    , optTOCDepth              :: Int     -- ^ Number of levels to include in TOC
    , optDumpArgs              :: Bool    -- ^ Output command-line arguments
    , optIgnoreArgs            :: Bool    -- ^ Ignore command-line arguments
    , optVerbosity             :: Verbosity  -- ^ Verbosity of diagnostic output
    , optTrace                 :: Bool  -- ^ Enable tracing
    , optLogFile               :: Maybe FilePath -- ^ File to write JSON log output
    , optFailIfWarnings        :: Bool    -- ^ Fail on warnings
    , optReferenceLinks        :: Bool    -- ^ Use reference links in writing markdown, rst
    , optReferenceLocation     :: ReferenceLocation -- ^ location for footnotes and link references in markdown output
    , optDpi                   :: Int     -- ^ Dpi
    , optWrap                  :: WrapOption  -- ^ Options for wrapping text
    , optColumns               :: Int     -- ^ Line length in characters
    , optFilters               :: [Filter] -- ^ Filters to apply
    , optEmailObfuscation      :: ObfuscationMethod
    , optIdentifierPrefix      :: String
    , optStripEmptyParagraphs  :: Bool -- ^ Strip empty paragraphs
    , optIndentedCodeClasses   :: [String] -- ^ Default classes for indented code blocks
    , optDataDir               :: Maybe FilePath
    , optCiteMethod            :: CiteMethod -- ^ Method to output cites
    , optListings              :: Bool       -- ^ Use listings package for code blocks
    , optPdfEngine             :: Maybe String -- ^ Program to use for latex/html -> pdf
    , optPdfEngineOpts         :: [String]   -- ^ Flags to pass to the engine
    , optSlideLevel            :: Maybe Int  -- ^ Header level that creates slides
    , optSetextHeaders         :: Bool       -- ^ Use atx headers for markdown level 1-2
    , optAscii                 :: Bool       -- ^ Prefer ascii output
    , optDefaultImageExtension :: String -- ^ Default image extension
    , optExtractMedia          :: Maybe FilePath -- ^ Path to extract embedded media
    , optTrackChanges          :: TrackChanges -- ^ Accept or reject MS Word track-changes.
    , optFileScope             :: Bool         -- ^ Parse input files before combining
    , optTitlePrefix           :: Maybe String     -- ^ Prefix for title
    , optCss                   :: [FilePath]       -- ^ CSS files to link to
    , optIpynbOutput           :: IpynbOutput      -- ^ How to treat ipynb output blocks
    , optIncludeBeforeBody     :: [FilePath]       -- ^ Files to include before
    , optIncludeAfterBody      :: [FilePath]       -- ^ Files to include after body
    , optIncludeInHeader       :: [FilePath]       -- ^ Files to include in header
    , optResourcePath          :: [FilePath] -- ^ Path to search for images etc
    , optRequestHeaders        :: [(String, String)] -- ^ Headers for HTTP requests
    , optEol                   :: LineEnding -- ^ Style of line-endings to use
    , optStripComments         :: Bool       -- ^ Skip HTML comments
    } deriving (Generic, Show)

instance FromYAML (Opt -> Opt) where
  parseYAML (Mapping _ _ m) =
    foldr (.) id <$> mapM doOpt (M.toList m)
  parseYAML n = failAtNode n "Expected a mapping"

doOpt :: (Node Pos, Node Pos) -> Parser (Opt -> Opt)
doOpt (k',v) = do
  k <- case k' of
         Scalar _ (SStr t) -> return t
         Scalar _ _ -> failAtNode k' "Non-string key"
         _ -> failAtNode k' "Non-scalar key"
  case k of
    "tab-stop" ->
      parseYAML v >>= \x -> return (\o -> o{ optTabStop = x })
    "preserve-tabs" ->
      parseYAML v >>= \x -> return (\o -> o{ optPreserveTabs = x })
    "standalone" ->
      parseYAML v >>= \x -> return (\o -> o{ optStandalone = x })
    "table-of-contents" ->
      parseYAML v >>= \x -> return (\o -> o{ optTableOfContents = x })
    "toc" ->
      parseYAML v >>= \x -> return (\o -> o{ optTableOfContents = x })
    "from" ->
      parseYAML v >>= \x -> return (\o -> o{ optFrom = unpack <$> x })
    "reader" ->
      parseYAML v >>= \x -> return (\o -> o{ optFrom = unpack <$> x })
    "to" ->
      parseYAML v >>= \x -> return (\o -> o{ optTo = unpack <$> x })
    "writer" ->
      parseYAML v >>= \x -> return (\o -> o{ optTo = unpack <$> x })
    "shift-heading-level-by" ->
      parseYAML v >>= \x -> return (\o -> o{ optShiftHeadingLevelBy = x })
    "template" ->
      parseYAML v >>= \x -> return (\o -> o{ optTemplate = unpack <$> x })
    "variables" ->
      parseYAML v >>= \x -> return (\o -> o{ optVariables = x })
    "metadata" ->
      parseYAML v >>= \x -> return (\o -> o{ optMetadata = contextToMeta x })
    "metadata-files" ->
      (parseYAML v >>= \x ->
                        return (\o -> o{ optMetadataFiles = map unpack x }))
    "metadata-file" -> -- allow either a list or a single value
      (parseYAML v >>= \x -> return (\o -> o{ optMetadataFiles = map unpack x }))
      <|>
      (parseYAML v >>= \x ->
                        return (\o -> o{ optMetadataFiles = [unpack x] }))
    "output-file" ->
      parseYAML v >>= \x -> return (\o -> o{ optOutputFile = unpack <$> x })
    "input-files" ->
      parseYAML v >>= \x -> return (\o -> o{ optInputFiles = map unpack x })
    "number-sections" ->
      parseYAML v >>= \x -> return (\o -> o{ optNumberSections = x })
    "number-offset" ->
      parseYAML v >>= \x -> return (\o -> o{ optNumberOffset = x })
    "section-divs" ->
      parseYAML v >>= \x -> return (\o -> o{ optSectionDivs = x })
    "incremental" ->
      parseYAML v >>= \x -> return (\o -> o{ optIncremental = x })
    "self-contained" ->
      parseYAML v >>= \x -> return (\o -> o{ optSelfContained = x })
    "html-q-tags" ->
      parseYAML v >>= \x -> return (\o -> o{ optHtmlQTags = x })
    "highlight-style" ->
      parseYAML v >>= \x -> return (\o -> o{ optHighlightStyle = unpack <$> x })
    "syntax-definition" ->
      (parseYAML v >>= \x ->
                return (\o -> o{ optSyntaxDefinitions = map unpack x }))
      <|>
      (parseYAML v >>= \x ->
             return (\o -> o{ optSyntaxDefinitions = [unpack x] }))
    "syntax-definitions" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optSyntaxDefinitions = map unpack x })
    "top-level-division" ->
      parseYAML v >>= \x -> return (\o -> o{ optTopLevelDivision = x })
    "html-math-method" ->
      parseYAML v >>= \x -> return (\o -> o{ optHTMLMathMethod = x })
    "abbreviations" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optAbbreviations = unpack <$> x })
    "reference-doc" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optReferenceDoc = unpack <$> x })
    "epub-subdirectory" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optEpubSubdirectory = unpack x })
    "epub-metadata" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optEpubMetadata = unpack <$> x })
    "epub-fonts" ->
      parseYAML v >>= \x -> return (\o -> o{ optEpubFonts = map unpack x })
    "epub-chapter-level" ->
      parseYAML v >>= \x -> return (\o -> o{ optEpubChapterLevel = x })
    "epub-cover-image" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optEpubCoverImage = unpack <$> x })
    "toc-depth" ->
      parseYAML v >>= \x -> return (\o -> o{ optTOCDepth = x })
    "dump-args" ->
      parseYAML v >>= \x -> return (\o -> o{ optDumpArgs = x })
    "ignore-args" ->
      parseYAML v >>= \x -> return (\o -> o{ optIgnoreArgs = x })
    "verbosity" ->
      parseYAML v >>= \x -> return (\o -> o{ optVerbosity = x })
    "trace" ->
      parseYAML v >>= \x -> return (\o -> o{ optTrace = x })
    "log-file" ->
      parseYAML v >>= \x -> return (\o -> o{ optLogFile = unpack <$> x })
    "fail-if-warnings" ->
      parseYAML v >>= \x -> return (\o -> o{ optFailIfWarnings = x })
    "reference-links" ->
      parseYAML v >>= \x -> return (\o -> o{ optReferenceLinks = x })
    "reference-location" ->
      parseYAML v >>= \x -> return (\o -> o{ optReferenceLocation = x })
    "dpi" ->
      parseYAML v >>= \x -> return (\o -> o{ optDpi = x })
    "wrap" ->
      parseYAML v >>= \x -> return (\o -> o{ optWrap = x })
    "columns" ->
      parseYAML v >>= \x -> return (\o -> o{ optColumns = x })
    "filters" ->
      parseYAML v >>= \x -> return (\o -> o{ optFilters = x })
    "email-obfuscation" ->
      parseYAML v >>= \x -> return (\o -> o{ optEmailObfuscation = x })
    "identifier-prefix" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optIdentifierPrefix = unpack x })
    "strip-empty-paragraphs" ->
      parseYAML v >>= \x -> return (\o -> o{ optStripEmptyParagraphs = x })
    "indented-code-classes" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optIndentedCodeClasses = map unpack x })
    "data-dir" ->
      parseYAML v >>= \x -> return (\o -> o{ optDataDir = unpack <$> x })
    "cite-method" ->
      parseYAML v >>= \x -> return (\o -> o{ optCiteMethod = x })
    "listings" ->
      parseYAML v >>= \x -> return (\o -> o{ optListings = x })
    "pdf-engine" ->
      parseYAML v >>= \x -> return (\o -> o{ optPdfEngine = unpack <$> x })
    "pdf-engine-opts" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optPdfEngineOpts = map unpack x })
    "pdf-engine-opt" ->
      (parseYAML v >>= \x ->
             return (\o -> o{ optPdfEngineOpts = map unpack x }))
      <|>
      (parseYAML v >>= \x ->
             return (\o -> o{ optPdfEngineOpts = [unpack x] }))
    "slide-level" ->
      parseYAML v >>= \x -> return (\o -> o{ optSlideLevel = x })
    "setext-headers" ->
      parseYAML v >>= \x -> return (\o -> o{ optSetextHeaders = x })
    "ascii" ->
      parseYAML v >>= \x -> return (\o -> o{ optAscii = x })
    "default-image-extension" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optDefaultImageExtension = unpack x })
    "extract-media" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optExtractMedia = unpack <$> x })
    "track-changes" ->
      parseYAML v >>= \x -> return (\o -> o{ optTrackChanges = x })
    "file-scope" ->
      parseYAML v >>= \x -> return (\o -> o{ optFileScope = x })
    "title-prefix" ->
      parseYAML v >>= \x -> return (\o -> o{ optTitlePrefix = unpack <$> x })
    "css" ->
      (parseYAML v >>= \x -> return (\o -> o{ optCss = map unpack x }))
      <|>
      (parseYAML v >>= \x -> return (\o -> o{ optCss = [unpack x] }))
    "ipynb-output" ->
      parseYAML v >>= \x -> return (\o -> o{ optIpynbOutput = x })
    "include-before-body" ->
      (parseYAML v >>= \x ->
             return (\o -> o{ optIncludeBeforeBody = map unpack x }))
      <|>
      (parseYAML v >>= \x ->
             return (\o -> o{ optIncludeBeforeBody = [unpack x] }))
    "include-after-body" ->
      (parseYAML v >>= \x ->
             return (\o -> o{ optIncludeAfterBody = map unpack x }))
      <|>
      (parseYAML v >>= \x ->
             return (\o -> o{ optIncludeAfterBody = [unpack x] }))
    "include-in-header" ->
      (parseYAML v >>= \x ->
             return (\o -> o{ optIncludeInHeader = map unpack x }))
      <|>
      (parseYAML v >>= \x ->
             return (\o -> o{ optIncludeInHeader = [unpack x] }))
    "resource-path" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optResourcePath = map unpack x })
    "request-headers" ->
      parseYAML v >>= \x ->
             return (\o -> o{ optRequestHeaders =
                              map (\(key,val) ->
                                     (unpack key, unpack val)) x })
    "eol" ->
      parseYAML v >>= \x -> return (\o -> o{ optEol = x })
    "strip-comments" ->
      parseYAML v >>= \x -> return (\o -> o  { optStripComments = x })
    _ -> failAtNode k' $ "Unknown option " ++ show k

-- | Defaults for command-line options.
defaultOpts :: Opt
defaultOpts = Opt
    { optTabStop               = 4
    , optPreserveTabs          = False
    , optStandalone            = False
    , optFrom                  = Nothing
    , optTo                    = Nothing
    , optTableOfContents       = False
    , optShiftHeadingLevelBy   = 0
    , optTemplate              = Nothing
    , optVariables             = mempty
    , optMetadata              = mempty
    , optMetadataFiles         = []
    , optOutputFile            = Nothing
    , optInputFiles            = []
    , optNumberSections        = False
    , optNumberOffset          = [0,0,0,0,0,0]
    , optSectionDivs           = False
    , optIncremental           = False
    , optSelfContained         = False
    , optHtmlQTags             = False
    , optHighlightStyle        = Just "pygments"
    , optSyntaxDefinitions     = []
    , optTopLevelDivision      = TopLevelDefault
    , optHTMLMathMethod        = PlainMath
    , optAbbreviations         = Nothing
    , optReferenceDoc          = Nothing
    , optEpubSubdirectory      = "EPUB"
    , optEpubMetadata          = Nothing
    , optEpubFonts             = []
    , optEpubChapterLevel      = 1
    , optEpubCoverImage        = Nothing
    , optTOCDepth              = 3
    , optDumpArgs              = False
    , optIgnoreArgs            = False
    , optVerbosity             = WARNING
    , optTrace                 = False
    , optLogFile               = Nothing
    , optFailIfWarnings        = False
    , optReferenceLinks        = False
    , optReferenceLocation     = EndOfDocument
    , optDpi                   = 96
    , optWrap                  = WrapAuto
    , optColumns               = 72
    , optFilters               = []
    , optEmailObfuscation      = NoObfuscation
    , optIdentifierPrefix      = ""
    , optStripEmptyParagraphs  = False
    , optIndentedCodeClasses   = []
    , optDataDir               = Nothing
    , optCiteMethod            = Citeproc
    , optListings              = False
    , optPdfEngine             = Nothing
    , optPdfEngineOpts         = []
    , optSlideLevel            = Nothing
    , optSetextHeaders         = True
    , optAscii                 = False
    , optDefaultImageExtension = ""
    , optExtractMedia          = Nothing
    , optTrackChanges          = AcceptChanges
    , optFileScope             = False
    , optTitlePrefix           = Nothing
    , optCss                   = []
    , optIpynbOutput           = IpynbOutputBest
    , optIncludeBeforeBody     = []
    , optIncludeAfterBody      = []
    , optIncludeInHeader       = []
    , optResourcePath          = ["."]
    , optRequestHeaders        = []
    , optEol                   = Native
    , optStripComments         = False
    }

contextToMeta :: Context Text -> Meta
contextToMeta (Context m) =
  Meta . M.mapKeys unpack . M.map valToMetaVal $ m

valToMetaVal :: Val Text -> MetaValue
valToMetaVal (MapVal (Context m)) =
  MetaMap . M.mapKeys unpack . M.map valToMetaVal $ m
valToMetaVal (ListVal xs) = MetaList $ map valToMetaVal xs
valToMetaVal (SimpleVal d) = MetaString (unpack $ render Nothing d)
valToMetaVal NullVal = MetaString ""

-- see https://github.com/jgm/pandoc/pull/4083
-- using generic deriving caused long compilation times
$(deriveJSON
   defaultOptions{ fieldLabelModifier = drop 11 . map toLower } ''IpynbOutput)
$(deriveJSON
   defaultOptions{ fieldLabelModifier = map toLower } ''LineEnding)
$(deriveJSON
   defaultOptions{ fieldLabelModifier =
                      camelCaseToHyphenated . dropWhile isLower
                 } ''Opt)