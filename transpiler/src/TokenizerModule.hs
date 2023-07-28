module TokenizerModule (tokenize, Div, toTag) where

data Div = Div 
    { isDefault :: Bool
    , content :: String
    , font :: String

    , br :: Int  ---------------
    , bg :: Int  -- BG colors -- 
    , bb :: Int  ---------------
    , ba :: Float

    , fr :: Int  ---------------
    , fg :: Int  -- FG colors --  
    , fb :: Int  ---------------
    , fa :: Float

    , margin :: String
    , padding :: String
    }


toTag :: Div -> String
toTag div = "<div style=\"background-color: rgba(" ++ show (br div) ++ ", " ++ show (bg div) ++ ", " ++ show (bb div) ++ ", " ++ show (ba div) ++ "); color: rgba(" ++ show (fr div) ++ ", " ++ show (fg div) ++ ", " ++ show (fb div) ++ " ," ++ show (fa div) ++ "); margin: " ++ margin div ++ "; padding: " ++ padding div ++ ";\">" ++ content div ++ "</div>\n"

errorDiv :: Div
errorDiv = Div 
    { isDefault = False
    , content = "this is error div"
    , font = "13px Arial, sans-serif"

    , br =   0  ---------------
    , bg =   0  -- BG colors -- 
    , bb =   0  ---------------
    , ba = 0.0

    , fr =   0  ---------------
    , fg =   0  -- FG colors --  
    , fb =   0  ---------------
    , fa =   1.0

    , margin = "0px"
    , padding = "20px"
    }


defaultDiv :: Div
defaultDiv = Div 
    { isDefault = False
    , content = ""
    , font = "0px Arial, sans-serif"

    , br =   0 ---------------
    , bg =   0  -- BG colors -- 
    , bb =   0 ---------------
    , ba = 0.0

    , fr =   0  ---------------
    , fg =   0  -- FG colors --  
    , fb =   0  ---------------
    , fa = 0.0

    , margin = "0px"
    , padding = "0px"
    }



tokenize :: String -> [Div]
tokenize [] = [errorDiv] 
tokenize code = parseLogic (lines code)

parseLogic :: [String] -> [Div]
parseLogic [] = [errorDiv]
parseLogic lines = keepDivs (map parse lines)

parse :: String -> Div
parse [] = defaultDiv
parse line = produceDiv (separateContent line)
    where
        separateContent :: String -> [String]
        separateContent [] = ["comment", "", ""]
        separateContent line
            | getType line == "div" = ["div"] ++ splitOnN line (findSecondChar line '\"' 0 0)
            | getType line == "style" = ["style"] ++ splitOnN line (findSecondChar line '#' 0 0) 
            | getType line == "comment" = ["comment", "", ""]
            | otherwise = ["comment", "", ""]

        findSecondChar :: String -> Char -> Int -> Int -> Int
        findSecondChar [] _ _ currentIndex = currentIndex
        findSecondChar (char:rest) finding foundCount currentIndex
            | char == finding && foundCount + 1 == 2 = currentIndex
            | char == finding = findSecondChar rest finding (foundCount + 1) (currentIndex + 1)
            | otherwise = findSecondChar rest finding foundCount (currentIndex + 1)


        -- make this work on empty chars on start of line it future
        getType :: String -> String
        getType (char:rest)
            | char == '"' = "div"
            | char == '#' = "style"
            | otherwise = "comment"

        splitOnN :: String -> Int -> [String]
        splitOnN (first:line) index = [take (index - 1) line, drop index line]

produceDiv :: [String] -> Div
produceDiv (first:rest)
    | first == "div" = processDiv rest
    | first == "class" = defaultDiv
    | otherwise = defaultDiv
        where
            processDiv :: [String] -> Div
            processDiv [] = defaultDiv
            processDiv (parsedContent:style) = styleDiv parsedContent style

            styleDiv :: String -> [String] -> Div
            styleDiv _ [] = defaultDiv
            styleDiv parsedContent (style:_) = defaultDiv { 
                isDefault = False,
                content = parsedContent,
                padding = getPadding style,
                margin = getMargin style
            }

            getPadding :: String -> String
            getPadding input = case dropWhile (/= "padding") (words input) of
                ("padding" : paddingValue : _) -> paddingValue
                _ -> "0px"

            getMargin :: String -> String
            getMargin input = case dropWhile (/= "margin") (words input) of
                ("margin" : marginValue : _) -> marginValue
                _ -> "0px"


keepDivs :: [Div] -> [Div]
keepDivs [] = []
keepDivs (div:rest)
    | isDefault div = keepDivs rest
    | otherwise = div : keepDivs rest
