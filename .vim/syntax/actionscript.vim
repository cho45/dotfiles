" Vim syntax file
" Language:     ActionScript
" Maintainer:   Manish Jethani <manish.jethani@gmail.com>
" URL:          http://geocities.com/manish_jethani/actionscript.vim
" Last Change:  2006 June 26

if exists("b:current_syntax")
  finish
endif

syn region  asStringDQ        start=+"+  skip=+\\\\\|\\"+  end=+"+
syn region  asStringSQ        start=+'+  skip=+\\\\\|\\'+  end=+'+
syn match   asNumber          "-\=\<\d\+L\=\>\|0[xX][0-9a-fA-F]\+\>"
syn region  asRegExp          start=+/+ skip=+\\\\\|\\/+ end=+/[gismx]\?\s*$+ end=+/[gismx]\?\s*[;,)]+me=e-1 oneline
" TODO: E4X

syn keyword asCommentTodo     TODO FIXME XXX TBD contained

syn match   asComment         "//.*$" contains=asCommentTodo
syn region  asComment         start="/\*"  end="\*/" contains=asCommentTodo

syn keyword asDirective       import include
syn match   asDirective       "\<use\s\+namespace\>"

syn keyword asAttribute       public private internal protected override final dynamic native static

syn keyword asDefinition      const var class extends interface implements package namespace
syn match   asDefinition        "\<function\(\s\+[gs]et\)\?\>"

syn keyword asGlobal          NaN Infinity undefined eval parseInt parseFloat isNaN isFinite decodeURI decodeURIComponent encodeURI encodeURIComponent

syn keyword asType            Object Function Array String Boolean Number Date Error XML
syn keyword asType            int uint void *

syn keyword asStatement       if else do while for with switch case default continue break return throw try catch finally
syn match   asStatement       "\<for\s\+each\>"

syn keyword asIdentifier      super this

syn keyword asConstant        null true false
syn keyword asOperator        new in is as typeof instanceof delete

syn match   asBraces          "[{}]"

" Flex metadata
syn keyword asMetadataTag     Bindable DefaultProperty Effect Event Exclude IconFile MaxChildren ResourceBundle Style contained
syn match   asMetadata        "^\s*\[.*" contains=asMetadataTag,asStringDQ,asComment

syn sync fromstart
syn sync maxlines=300

hi def link asStringDQ        String
hi def link asStringSQ        String
hi def link asNumber          Number
hi def link asRegExp          Special
hi def link asCommentTodo     Todo
hi def link asComment         Comment
hi def link asDirective       Include
hi def link asAttribute       Define
hi def link asDefinition      Structure
hi def link asGlobal          Macro
hi def link asType            Type
hi def link asStatement       Statement
hi def link asIdentifier      Identifier
hi def link asConstant        Constant
hi def link asOperator        Operator
hi def link asBraces          Function
hi def link asMetadataTag     PreProc


" from http://www.vim.org/scripts/script.php?script_id=1061
syn keyword actionScriptConditional                     if else and or not
syn keyword actionScriptRepeat                          do while for in
syn keyword actionScriptCase                            break continue switch case default
syn keyword actionScriptConstructor                     new
syn keyword actionScriptObjects                         arguments Array Boolean Date _global Math Number Object String super var this Accessibility Color Key _level Mouse _root Selection Sound Stage System TextFormat LoadVars XML XMLSocket XMLNode LoadVars Button TextField TextSnapshot CustomActions Error ContextMenu ContextMenuItem NetConnection NetStream Video PrintJob MovieClipLoader StyleSheet Camera LocalConnection Microphone SharedObject MovieClip
syn keyword actionScriptStatement                       return with
syn keyword actionScriptFunction                        function on onClipEvent
syn keyword actionScriptValue                           true false undefined null NaN void
syn keyword actionScriptArray                           concat join length pop push reverse shift slice sort sortOn splice toString unshift
syn keyword actionScriptDate                            getDate getDay getFullYear getHours getMilliseconds getMinutes getMonth getSeconds getTime getTimezoneOffset getUTCDate getUTCDay getUTCFullYear getUTCHours getUTCMilliseconds getUTCMinutes getUTCMonth getUTCSeconds getYear setDate setFullYear setHours setMilliseconds setMinutes setMonth setSeconds setTime setUTCDate setUTCFullYear setUTCHours setUTCMilliseconds setUTCMinutes setUTCMonth setUTCSeconds setYear UTC
syn keyword actionScriptMath                            abs acos asin atan atan2 ceil cos E exp floor log LOG2E LOG10E LN2 LN10 max min PI pow random round sin sqrt SQRT1_2 SQRT2 tan -Infinity Infinity
syn keyword actionScriptNumberObj                       MAX_VALUE MIN_VALUE NaN NEGATIVE_INFINITY POSITIVE_INFINITY valueOf
syn keyword actionScriptObject                          addProperty __proto__ registerClass toString unwatch valueOf watch
syn keyword actionScriptString                          charAt charCodeAt concat fromCharCode indexOf lastIndexOf length slice split substr substring toLowerCase toUpperCase add le lt gt ge eq ne chr mbchr mblength mbord mbsubstring ord
syn keyword actionScriptColor                           getRGB getTransform setRGB setTransform
syn keyword actionScriptKey                             addListener BACKSPACE CAPSLOCK CONTROL DELETEKEY DOWN END ENTER ESCAPE getAscii getCode HOME INSERT isDown isToggled LEFT onKeyDown onKeyUp PGDN PGUP removeListener RIGHT SHIFT SPACE TAB UP ALT
syn keyword actionScriptMouse                           hide onMouseDown onMouseUp onMouseMove show onMouseWheel
syn keyword actionScriptSelection                       getBeginIndex getCaretIndex getEndIndex getFocus setFocus setSelection
syn keyword actionScriptSound                           attachSound duration getBytesLoaded getBytesTotal getPan getTransform getVolume loadSound onLoad onSoundComplete position setPan setTransform setVolume start stop onID3
syn keyword actionScriptStage                           align height onResize scaleMode width
syn keyword actionScriptSystem                          capabilities hasAudioEncoder hasAccessibility hasAudio hasMP3 language manufacturer os pixelAspectRatio screenColor screenDPI screenResolution.x screenResolution.y version hasVideoEncoder security useCodepage exactSettings hasEmbeddedVideo screenResolutionX screenResolutionY input isDebugger serverString hasPrinting playertype hasStreamingAudio hasScreenBroadcast hasScreenPlayback hasStreamingVideo avHardwareDisable localFileReadDisable windowlesDisable
syn keyword actionScriptTextFormat                      align blockIndent bold bullet color font getTextExtent indent italic leading leftMargin rightMargin size tabStops target underline url
syn keyword actionScriptCommunication                   contentType getBytesLoaded getBytesTotal load loaded onLoad send sendAndLoad toString   addRequestHeader fscommand MMExecute
syn keyword actionScriptXMLSocket                       close connect onClose onConnect onData onXML
syn keyword actionScriptTextField                       autoSize background backgroundColor border borderColor bottomScroll embedFonts _focusrect getDepth getFontList getNewTextFormat getTextFormat hscroll html htmlText maxChars maxhscroll maxscroll multiline onChanged onScroller onSetFocus _parent password _quality removeTextField replaceSel replaceText restrict selectable setNewTextFormat setTextFormat text textColor textHeight textWidth type variable wordWrap condenseWhite mouseWheelEnabled textFieldHeight textFieldWidth ascent descent
syn keyword actionScriptMethods                         callee caller _alpha attachMovie beginFill beginGradientFill clear createEmptyMovieClip createTextField _currentframe curveTo _droptarget duplicateMovieClip enabled endFill focusEnabled _framesloaded getBounds globalToLocal gotoAndPlay gotoAndStop _height _highquality hitArea hitTest lineStyle lineTo loadMovie loadMovieNum loadVariables loadVariablesNum localToGlobal moveTo _name nextFrame onDragOut onDragOver onEnterFrame onKeyDown onKeyUp onKillFocus onMouseDown onMouseMove onMouseUp onPress onRelease onReleaseOutside onRollOut onRollOver onUnload play prevFrame removeMovieClip _rotation setMask _soundbuftime startDrag stopDrag swapDepths tabChildren tabIndex _target _totalframes trackAsMenu unloadMovie unloadMovieNum updateAfterEvent _url useHandCursor _visible _width _x _xmouse _xscale _y _ymouse _yscale tabEnabled asfunction call setInterval clearInterval setProperty stopAllSounds #initclip #endinitclip delete unescape escape eval apply prototype getProperty getTimer getURL getVersion ifFrameLoaded #include instanceof int new nextScene parseFloat parseInt prevScene print printAsBitmap printAsBitmapNum printNum scroll set targetPath tellTarget toggleHighQuality trace typeof isActive getInstanceAtDepth getNextHighestDepth getNextDepth getSWFVersion getTextSnapshot isFinite isNAN updateProperties _lockroot get install list uninstall showMenu onSelect builtInItems save zoom quality loop rewind forward_back customItems caption separatorBefore visible attachVideo bufferLength bufferTime currentFps onStatus pause seek setBuffertime smoothing time bytesLoaded bytesTotal addPage paperWidth paperHeight pageWidth pageHeight orientation loadClip unloadClip getProgress onLoadStart onLoadProgress onLoadComplete onLoadInit onLoadError styleSheet copy hideBuiltInItem transform activityLevel allowDomain allowInsecureDomain attachAudio bandwidth deblocking domain flush fps gain getLocal getRemote getSize index isConnected keyFrameInterval liveDelay loopback motionLevel motionTimeOut menu muted names onActivity onSync publish rate receiveAudio receiveVideo setFps setGain setKeyFrameInterval setLoopback setMode setMotionLevel setQuality setRate setSilenceLevel setUseEchoSuppression showSettings setClipboard silenceLevel silenceTimeOut useEchoSuppression
syn match   actionScriptBraces                          "([{}])"
syn keyword actionScriptException                       try catch finally throw name message
syn keyword actionScriptXML                             attributes childNodes cloneNode createElement createTextNode docTypeDecl status firstChild hasChildNodes lastChild insertBefore nextSibling nodeName nodeType nodeValue parentNode parseXML previousSibling removeNode xmlDecl ignoreWhite
syn keyword actionScriptArrayConstant                   CASEINSENSITIVE DESCENDING UNIQUESORT RETURNINDEXEDARRAY NUMERIC
syn keyword actionScriptStringConstant                  newline
syn keyword actionScriptEventConstant                   press release releaseOutside rollOver rollOut dragOver dragOut enterFrame unload mouseMove mouseDown mouseUp keyDown keyUp data
syn keyword actionScriptTextSnapshot                    getCount setSelected getSelected getText getSelectedText hitTestTextNearPos findText setSelectColor
syn keyword actionScriptID3                             id3 artist album songtitle year genre track comment COMM TALB TBPM TCOM TCON TCOP TDAT TDLY TENC TEXT TFLT TIME TIT1 TIT2 TIT3 TKEY TLAN TLEN TMED TOAL TOFN TOLY TOPE TORY TOWN TPE1 TPE2 TPE3 TPE4 TPOS TPUB TRCK TRDA TRSN TRSO TSIZ TSRX TSSE TYER WXXX
syn keyword actionScriptAS2                             class extends public private static interface implements import dynamic
syn keyword actionScriptStyleSheet                      parse parseCSS getStyle setStyle getStyleNames
syn keyword flash8Functions                             onMetaData onCuePoint flashdisplay flashexternal flashfilters flashgeom flashnet flashtext addCallback applyFilter browse cancel clone colorTransform  containsPoint containsRectangle copyChannel copyPixels createBox createGradientBox deltaTransformPoint dispose download draw equals fillRect floodFill generateFilterRect getColorBoundsRect getPixel getPixel32 identity inflate inflatePoint interpolate intersection intersects invert isEmpty loadBitmap merge noise normalize offsetPoint paletteMap perlinNoise pixelDissolve polar rotate scale setAdvancedAntialiasingTable setEmpty setPixel setPixel32 subtract threshold transformPoint translate union upload
syn keyword flash8Constants                             ALPHANUMERIC_FULL ALPHANUMERIC_HALF CHINESE JAPANESE_HIRAGANA JAPANESE_KATAKANA_FULL JAPANESE_KATAKANA_HALF KOREAN UNKNOWN
syn keyword flash8Properties                            appendChild cacheAsBitmap opaqueBackground scrollRect keyPress #initclip #endinitclip kerning letterSpacing onHTTPStatus lineGradientStyle IME windowlessDisable hasIME hideBuiltInItems onIMEComposition getEnabled setEnabled getConversionMode setConversionMode setCompositionString doConversion idMap antiAliasType available bottom bottomRight concatenatedColorTransform concatenatedMatrix creationDate creator fileList maxLevel modificationDate pixelBounds rectangle rgb top topLeft attachBitmap beginBitmapFill blendMode filters getRect scale9Grid gridFitType sharpness thickness
syn keyword flash8Classes                               BevelFilter BitmapData BitmapFilter BlurFilter ColorMatrixFilter ColorTransform ConvolutionFilter DisplacementMapFilter DropShadowFilter ExternalInterface FileReference FileReferenceList GlowFilter GradientBevelFilter GradientGlowFilter Matrix Point Rectangle TextRenderer
syn keyword actionScriptInclude                         #include #initClip #endInitClip

hi def link actionScriptComment                 Comment
hi def link actionScriptLineComment             Comment
hi def link actionScriptSpecial                 Special
hi def link actionScriptStringS                 String
hi def link actionScriptStringD                 String
hi def link actionScriptCharacter               Character
hi def link actionScriptSpecialCharacter        actionScriptSpecial
hi def link actionScriptNumber                  actionScriptValue
hi def link actionScriptBraces                  Function
hi def link actionScriptError                   Error
hi def link actionScrParenError                 actionScriptError
hi def link actionScriptInParen                 actionScriptError
hi def link actionScriptConditional             Conditional
hi def link actionScriptRepeat                  Repeat
hi def link actionScriptCase                    Label
hi def link actionScriptConstructor             Operator
hi def link actionScriptObjects                 Operator
hi def link actionScriptStatement               Statement
hi def link actionScriptFunction                Function
hi def link actionScriptValue                   Boolean
hi def link actionScriptArray                   Type
hi def link actionScriptDate                    Type
hi def link actionScriptMath                    Type
hi def link actionScriptNumberObj               Type
hi def link actionScriptObject                  Function
hi def link actionScriptString                  Type
hi def link actionScriptColor                   Type
hi def link actionScriptKey                     Type
hi def link actionScriptMouse                   Type
hi def link actionScriptSelection               Type
hi def link actionScriptSound                   Type
hi def link actionScriptStage                   Type
hi def link actionScriptSystem                  Type
hi def link actionScriptTextFormat              Type
hi def link actionScriptCommunication           Type
hi def link actionScriptXMLSocket               Type
hi def link actionScriptTextField               Type
hi def link actionScriptMethods                 Statement
hi def link actionScriptException               Exception
hi def link actionScriptXML                     Type
hi def link actionScriptArrayConstant           Constant
hi def link actionScriptStringConstant          Constant
hi def link actionScriptEventConstant           Constant
hi def link actionScriptTextSnapshot            Type
hi def link actionScriptID3                     Type
hi def link actionScriptAS2                     Function
hi def link actionScriptStyleSheet              Type
hi def link flash8Constants                     Constant
hi def link flash8Functions                     Function
hi def link flash8Properties                    Type
hi def link flash8Classes                       Type
hi def link actionScriptInclude                 Include

let b:current_syntax = "actionscript"

" vim: ts=8
