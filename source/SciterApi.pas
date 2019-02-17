{*******************************************************}
{                                                       }
{  Sciter API                                           }
{  Copyright (c) Dmitry Baranov                         }
{                                                       }
{  This unit uses Sciter Engine,                        }
{  copyright Terra Informatica Software, Inc.           }
{  (http://terrainformatica.com/).                      }
{                                                       }
{*******************************************************}

unit SciterApi;

interface

uses
  Windows, Classes, SysUtils, TypInfo, ActiveX, RTTI, Variants, TiScriptApi;

const
  SIH_REPLACE_CONTENT      = 0;
  SIH_INSERT_AT_START      = 1;
  SIH_APPEND_AFTER_LAST    = 2;
  SOH_REPLACE              = 3;
  SOH_INSERT_BEFORE        = 4;
  SOH_INSERT_AFTER         = 5;

const
  HV_OK_TRUE               = -1;
  HV_OK                    = 0;
  HV_BAD_PARAMETER         = 1;
  HV_INCOMPATIBLE_TYPE     = 2;

const
  SC_LOAD_DATA             = $1;
  SC_DATA_LOADED           = $2;
  SC_DOCUMENT_COMPLETE     = $3 deprecated;
  SC_ATTACH_BEHAVIOR       = $4;
  SC_ENGINE_DESTROYED      = $5;
  SC_POSTED_NOTIFICATION   = $6;

const
  LOAD_OK     : UINT       = 0;
  LOAD_DISCARD: UINT       = 1;
  LOAD_DELAYED: UINT       = 2;
  LOAD_MYSELF : UINT       = 3;

type

  SCDOM_RESULT =
  (
    SCDOM_OK                = 0,
    SCDOM_INVALID_HWND      = 1,
    SCDOM_INVALID_HANDLE    = 2,
    SCDOM_PASSIVE_HANDLE    = 3,
    SCDOM_INVALID_PARAMETER = 4,
    SCDOM_OPERATION_FAILED  = 5,
    SCDOM_OK_NOT_HANDLED    = -1,
    SCDOM_DUMMY             = MAXINT
  );

  REQUEST_RESULT =
  (
    REQUEST_OK               = 0,
    REQUEST_BAD_PARAM        = 1, // bad parameter
    REQUEST_FAILURE          = 2, // operation failed, e.g. index out of bounds
    REQUEST_NOTSUPPORTED     = 3, // the platform does not support requested feature
    REQUEST_PANIC            = -1 // e.g. not enough memory
  );

  REQUEST_RQ_TYPE =
  (
    RRT_GET                  = 1,
    RRT_POST                 = 2,
    RRT_PUT                  = 3,
    RRT_DELETE               = 4,
    RRT_FORCE_DWORD          = $FFFFFFFF
  );

  PREQUEST_STATE = ^REQUEST_STATE;
  REQUEST_STATE =
  (
    RS_PENDING               = 0,
    RS_SUCCESS               = 1, // completed successfully
    RS_FAILURE               = 2, // completed with failure
    RS_FORCE_DWORD           = $FFFFFFFF
  );

  HWINDOW = HWND;

  HREQUEST = Pointer;

  HELEMENT = Pointer;

  HSARCHIVE = Pointer;

  LPVOID   = Pointer;

  UINT_PTR = UINT;

  LPCSTR_RECEIVER = procedure(str: PAnsiChar; str_length: UINT; param: Pointer); stdcall;
  PLPCSTR_RECEIVER = ^LPCSTR_RECEIVER;

  LPCWSTR_RECEIVER = procedure(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
  PLPCWSTR_RECEIVER = ^LPCWSTR_RECEIVER;

  LPCBYTE_RECEIVER = procedure(bytes: PByte; num_bytes: UINT; param: Pointer); stdcall;
  PLPCBYTE_RECEIVER = ^LPCBYTE_RECEIVER;

  SCITER_CALLBACK_NOTIFICATION = record
    code: UINT;
    hwnd: HWINDOW;
  end;
  LPSCITER_CALLBACK_NOTIFICATION = ^SCITER_CALLBACK_NOTIFICATION;

  SciterHostCallback = function(pns: LPSCITER_CALLBACK_NOTIFICATION; callbackParam: Pointer): UINT; stdcall;
  LPSciterHostCallback = ^SciterHostCallback;


  ElementEventProc = function(tag: Pointer; he: HELEMENT; evtg: UINT; prms: Pointer): BOOL; stdcall;
  LPELEMENT_EVENT_PROC = ^ElementEventProc;


  PSciterResourceType = ^SciterResourceType;
  SciterResourceType { NB: UINT }  =
  (
    RT_DATA_HTML   = 0,
    RT_DATA_IMAGE  = 1,
    RT_DATA_STYLE  = 2,
    RT_DATA_CURSOR = 3,
    RT_DATA_SCRIPT = 4,
    RT_DATA_RAW    = 5,
    RT_DATA_FONT,
    RT_DATA_SOUND,
    RT_DATA_FORCE_DWORD = MAXINT
  );

  SciterGFXLayer =
  (
    GFX_LAYER_GDI = 1,
    GFX_LAYER_WARP = 2,
    GFX_LAYER_D2D = 3,
    GFX_LAYER_SKIA = 4,
    GFX_LAYER_SKIA_OPENGL = 5,
    GFX_LAYER_AUTO = $FFFF
  );

  SciterRuntimeFeatures =
  (
    ALLOW_FILE_IO = 1,
    ALLOW_SOCKET_IO = 2,
    ALLOW_EVAL = 4,
    ALLOW_SYSINFO = 8
  );

  SCITER_RT_OPTIONS { NB: UINT_PTR } = (
   SCITER_SMOOTH_SCROLL = 1,      // value:TRUE - enable, value:FALSE - disable, enabled by default
   SCITER_CONNECTION_TIMEOUT = 2, // value: milliseconds, connection timeout of http client
   SCITER_HTTPS_ERROR = 3,        // value: 0 - drop connection, 1 - use builtin dialog, 2 - accept connection silently
   SCITER_FONT_SMOOTHING = 4,     // value: 0 - system default, 1 - no smoothing, 2 - std smoothing, 3 - clear type
   SCITER_TRANSPARENT_WINDOW = 6, // Windows Aero support, value:
                                  // 0 - normal drawing,
                                  // 1 - window has transparent background after calls DwmExtendFrameIntoClientArea() or DwmEnableBlurBehindWindow().
   SCITER_SET_GPU_BLACKLIST  = 7, // hWnd = NULL,
                                  // value = LPCBYTE, json - GPU black list, see: gpu-blacklist.json resource.
   SCITER_SET_SCRIPT_RUNTIME_FEATURES = 8, // value - combination of SCRIPT_RUNTIME_FEATURES flags.
   SCITER_SET_GFX_LAYER = 9,      // hWnd = NULL, value - GFX_LAYER
   SCITER_SET_DEBUG_MODE = 10,    // hWnd, value - TRUE/FALSE
   SCITER_SET_UX_THEMING = 11,    // hWnd = NULL, value - BOOL, TRUE - the engine will use "unisex" theme that is common for all platforms.
                                  // That UX theme is not using OS primitives for rendering input elements. Use it if you want exactly
                                  // the same (modulo fonts) look-n-feel on all platforms.
   SCITER_ALPHA_WINDOW  = 12,     // hWnd, value - TRUE/FALSE - window uses per pixel alpha (e.g. WS_EX_LAYERED/UpdateLayeredWindow() window)
   SCITER_RT_OPTIONS_DUMMY = MAXINT
  );

  SCN_LOAD_DATA = record
             code: UINT;
             hwnd: HWINDOW;
              uri: LPCWSTR;
          outData: PBYTE;
      outDataSize: UINT;
         dataType: SciterResourceType;
        requestId: Pointer;
        principal: HELEMENT;
        initiator: HELEMENT;
  end;
  LPSCN_LOAD_DATA = ^SCN_LOAD_DATA;


  SCN_DATA_LOADED = record
            code: UINT;
            hwnd: HWINDOW;
             uri: LPCWSTR;
            data: PByte;
        dataSize: UINT;
        dataType: SciterResourceType;
          status: UINT;
  end;
  LPSCN_DATA_LOADED = ^SCN_DATA_LOADED;


  SCN_ATTACH_BEHAVIOR = record
            code: UINT;
            hwnd: HWINDOW;
         element: HELEMENT;
    behaviorName: PAnsiChar;
     elementProc: LPELEMENT_EVENT_PROC;
      elementTag: LPVOID
  end;
  LPSCN_ATTACH_BEHAVIOR = ^SCN_ATTACH_BEHAVIOR;


  SCN_ENGINE_DESTROYED = record
    code: UINT;
    hwnd: HWINDOW
  end;
  LPSCN_ENGINE_DESTROYED = ^SCN_ENGINE_DESTROYED;


  SCN_POSTED_NOTIFICATION = record
       code: UINT;
       hwnd: HWINDOW;
     wparam: UINT_PTR;
     lparam: UINT_PTR;
    lreturn: UINT_PTR;
  end;
  LPSCN_POSTED_NOTIFICATION = ^SCN_POSTED_NOTIFICATION;

  TProcPointer = procedure; stdcall;

  DEBUG_OUTPUT_PROC = procedure(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
  PDEBUG_OUTPUT_PROC = ^DEBUG_OUTPUT_PROC;

  SciterElementCallback = function(he: HELEMENT; Param: Pointer): BOOL; stdcall;
  PSciterElementCallback = ^SciterElementCallback;

  VALUE_STRING_CVT_TYPE =
  (
    CVT_SIMPLE,
    CVT_JSON_LITERAL,
    CVT_JSON_MAP,
    CVT_XJSON_LITERAL,
    VALUE_STRING_CVT_TYPE_DUMMY = MAXINT
  );

  TSciterValueType =
  (
    T_UNDEFINED,
    T_NULL,
    T_BOOL,
    T_INT,
    T_FLOAT,
    T_STRING,
    T_DATE,
    T_CURRENCY,
    T_LENGTH,
    T_ARRAY,
    T_MAP,
    T_FUNCTION,
    T_BYTES,
    T_OBJECT,
    T_DOM_OBJECT,
    T_DUMMY = MAXINT
  );

  TSciterValueUnitTypeInt =
  (
    UT_INT_INT = 0,
    UT_INT_EM = 1,
    UT_INT_EX = 2,
    UT_INT_PR = 3,
    UT_INT_SP = 4,
    UT_INT_RESERVED1 = 5,
    UT_INT_RESERVED2 = 6,
    UT_INT_PX = 7,
    UT_INT_IN = 8,
    UT_INT_CM = 9,
    UT_INT_MM = 10,
    UT_INT_PT = 11,
    UT_INT_PC = 12,
    UT_INT_DIP = 13,
    UT_INT_RESERVED3 = 14,
    UT_INT_COLOR = 15,
    UT_INT_URL   = 16,
    UT_INT_DUMMY = MAXINT
  );

  TSciterValueUnitTypeObject =
  (
    UT_OBJECT_ARRAY,
    UT_OBJECT_OBJECT,
    UT_OBJECT_CLASS,
    UT_OBJECT_NATIVE,
    UT_OBJECT_FUNCTION,
    UT_OBJECT_ERROR,
    UT_OBJECT_DUMMY = MAXINT
  );

  TSciterValueUnitTypeString =
  (
    UT_STRING_STRING = 0,
    UT_STRING_ERROR  = 1,
    UT_STRING_SECURE = 2,
    UT_STRING_SYMBOL = $ffff,
    UT_STRING_DUMMY = MAXINT
  );

  EVENT_GROUPS =
  (
    HANDLE_INITIALIZATION        = $0000,
    HANDLE_MOUSE                 = $0001,
    HANDLE_KEY                   = $0002,
    HANDLE_FOCUS                 = $0004,
    HANDLE_SCROLL                = $0008,
    HANDLE_TIMER                 = $0010,
    HANDLE_SIZE                  = $0020,
    HANDLE_DATA_ARRIVED          = $080,
    HANDLE_BEHAVIOR_EVENT        = $0100,
    HANDLE_METHOD_CALL           = $0200,
    HANDLE_SCRIPTING_METHOD_CALL = $0400,
    HANDLE_TISCRIPT_METHOD_CALL  = $0800,
    HANDLE_EXCHANGE              = $1000,
    HANDLE_GESTURE               = $2000,
    HANDLE_ALL                   = $FFFF,
    SUBSCRIPTIONS_REQUEST        = -1,
    EVENT_GROUPS_DUMMY           = MAXINT
  );

  ELEMENT_STATE_BITS =
  (
    STATE_LINK             = $00000001,
    STATE_HOVER            = $00000002,
    STATE_ACTIVE           = $00000004,
    STATE_FOCUS            = $00000008,
    STATE_VISITED          = $00000010,
    STATE_CURRENT          = $00000020,
    STATE_CHECKED          = $00000040,
    STATE_DISABLED         = $00000080,
    STATE_READONLY         = $00000100,
    STATE_EXPANDED         = $00000200,
    STATE_COLLAPSED        = $00000400,
    STATE_INCOMPLETE       = $00000800,
    STATE_ANIMATING        = $00001000,
    STATE_FOCUSABLE        = $00002000,
    STATE_ANCHOR           = $00004000,
    STATE_SYNTHETIC        = $00008000,
    STATE_OWNS_POPUP       = $00010000,
    STATE_TABFOCUS         = $00020000,
    STATE_EMPTY            = $00040000,
    STATE_BUSY             = $00080000,
    STATE_DRAG_OVER        = $00100000,
    STATE_DROP_TARGET      = $00200000,
    STATE_MOVING           = $00400000,
    STATE_COPYING          = $00800000,
    STATE_DRAG_SOURCE      = $01000000,
    STATE_DROP_MARKER      = $02000000,
    STATE_PRESSED          = $04000000,
    STATE_POPUP            = $08000000,
    STATE_IS_LTR           = $10000000,
    STATE_IS_RTL           = $20000000,
    ELEMENT_STATE_BITS_DUMMY = MAXINT
  );

  ELEMENT_AREAS =
  (
    ROOT_RELATIVE      = $1,
    SELF_RELATIVE      = $2,
    CONTAINER_RELATIVE = $3,
    VIEW_RELATIVE      = $4,
    CONTENT_BOX        = $0,
    PADDING_BOX        = $10,
    BORDER_BOX         = $20,
    MARGIN_BOX         = $30,
    BACK_IMAGE_AREA    = $40,
    FORE_IMAGE_AREA    = $50,
    SCROLLABLE_AREA    = $60,
    ELEMENT_AREAS_DUMMY = MAXINT
  );

  TSciterValue = record
    t: UINT;
    u: UINT;
    d: UInt64;
  end;
  PSciterValue = ^TSciterValue;

  TSciterValueArray = array[0..$FFFF] of TSciterValue;
  PSciterValueArray = ^TSciterValueArray;

  BEHAVIOR_METHOD_IDENTIFIERS =
  (
    DO_CLICK = 0,
    GET_TEXT_VALUE = 1,
    SET_TEXT_VALUE,
      // p - TEXT_VALUE_PARAMS

    TEXT_EDIT_GET_SELECTION,
      // p - TEXT_EDIT_SELECTION_PARAMS

    TEXT_EDIT_SET_SELECTION,
      // p - TEXT_EDIT_SELECTION_PARAMS

    // Replace selection content or insert text at current caret position.
    // Replaced text will be selected.
    TEXT_EDIT_REPLACE_SELECTION,
      // p - TEXT_EDIT_REPLACE_SELECTION_PARAMS

    // Set value of type="vscrollbar"/"hscrollbar"
    SCROLL_BAR_GET_VALUE,
    SCROLL_BAR_SET_VALUE,

    TEXT_EDIT_GET_CARET_POSITION,
    TEXT_EDIT_GET_SELECTION_TEXT, // p - TEXT_SELECTION_PARAMS
    TEXT_EDIT_GET_SELECTION_HTML, // p - TEXT_SELECTION_PARAMS
    TEXT_EDIT_CHAR_POS_AT_XY,     // p - TEXT_EDIT_CHAR_POS_AT_XY_PARAMS

    IS_EMPTY      = $FC,       // p - IS_EMPTY_PARAMS // set VALUE_PARAMS::is_empty (false/true) reflects :empty state of the element.
    GET_VALUE     = $FD,       // p - VALUE_PARAMS
    SET_VALUE     = $FE,       // p - VALUE_PARAMS

    FIRST_APPLICATION_METHOD_ID = $100,
    BEHAVIOR_METHOD_IDENTIFIERS_DUMMY = MAXINT
  );

  METHOD_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
  end;
  PMETHOD_PARAMS = ^METHOD_PARAMS;

  TEXT_VALUE_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    text: PWideChar;
    length: UINT;
  end;
  PTEXT_VALUE_PARAMS = ^TEXT_VALUE_PARAMS;

  VALUE_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    val: TSciterValue;
  end;
  PVALUE_PARAMS = ^VALUE_PARAMS;

  TEXT_EDIT_SELECTION_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    selection_start: UINT;
    selection_end: UINT;
  end;
  PTEXT_EDIT_SELECTION_PARAMS = ^TEXT_EDIT_SELECTION_PARAMS;

  TEXT_EDIT_REPLACE_SELECTION_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    text: PWideChar;
    text_length: UINT;
  end;
  PTEXT_EDIT_REPLACE_SELECTION_PARAMS = ^TEXT_EDIT_REPLACE_SELECTION_PARAMS;

  TEXT_EDIT_CHAR_POS_AT_XY_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    x: Integer; // in
    y: Integer; // in
    char_pos: Integer; // out
    he: HELEMENT; // out
    he_pos: Integer; // out
  end;
  PTEXT_EDIT_CHAR_POS_AT_XY_PARAMS = ^TEXT_EDIT_CHAR_POS_AT_XY_PARAMS;

  IS_EMPTY_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    is_empty: UINT;
  end;
  PIS_EMPTY_PARAMS = ^IS_EMPTY_PARAMS;

  REQUEST_PARAM = record
    name: PWideChar;
    value: PWideChar;
  end;
  PREQUEST_PARAM = ^REQUEST_PARAM;

  BEHAVIOR_EVENTS =
  (
    BEHAVIOR_EVENTS_ALL = -1, // doesn't exist in sciter api

    BUTTON_CLICK = 0,
    BUTTON_PRESS = 1,
    BUTTON_STATE_CHANGED = 2,
    EDIT_VALUE_CHANGING = 3,
    EDIT_VALUE_CHANGED = 4,
    SELECT_SELECTION_CHANGED = 5,
    SELECT_STATE_CHANGED = 6,
    POPUP_REQUEST   = 7,
    POPUP_READY     = 8,
    POPUP_DISMISSED = 9,
    MENU_ITEM_ACTIVE = $A,
    MENU_ITEM_CLICK = $B,
    CONTEXT_MENU_REQUEST = $10,
    VISIUAL_STATUS_CHANGED = $11,
    DISABLED_STATUS_CHANGED = $12,
    POPUP_DISMISSING = $13,
    CONTENT_CHANGED = $15,
    HYPERLINK_CLICK = $80,
    ELEMENT_COLLAPSED = $90,
    ELEMENT_EXPANDED = $91,
    ACTIVATE_CHILD = $91,
    //DO_SWITCH_TAB = ACTIVATE_CHILD
    //INIT_DATA_VIEW,
    //ROWS_DATA_REQUEST,
    UI_STATE_CHANGED = $95,
    FORM_SUBMIT = $96,
    FORM_RESET = $97,
    DOCUMENT_COMPLETE = $98,
    HISTORY_PUSH = $99,
    HISTORY_DROP = $9A,
    HISTORY_PRIOR = $9B,
    HISTORY_NEXT = $9C,
    HISTORY_STATE_CHANGED = $9D,
    CLOSE_POPUP = $9E,
    REQUEST_TOOLTIP = $9F,
    ANIMATION         = $A0,
    DOCUMENT_CREATED  = $C0,
    VIDEO_INITIALIZED = $D1,
    VIDEO_STARTED     = $D2,
    VIDEO_STOPPED     = $D3,
    VIDEO_BIND_RQ     = $D4,
    FIRST_APPLICATION_EVENT_CODE = $100,
    BEHAVIOR_EVENTS_DUMMY = MAXINT // doesn't exist in sciter api, used for sizeof(uint) alignment
  );

  CLICK_REASON =
  (
    BY_MOUSE_CLICK,
    BY_KEY_CLICK,
    SYNTHESIZED,
    BY_MOUSE_ON_ICON,
    EVENT_REASON_DUMMY = MAXINT
  );

  EDIT_CHANGED_REASON =
  (
    BY_INS_CHAR,
    BY_INS_CHARS,
    BY_DEL_CHAR,
    BY_DEL_CHARS,
    BY_UNDO_REDO,
    EDIT_CHANGED_REASON_DUMMY = MAXINT
  );

  BEHAVIOR_EVENT_PARAMS = record
         cmd: BEHAVIOR_EVENTS;
    heTarget: HELEMENT;
          he: HELEMENT;
      reason: UINT_PTR;
        data: TSciterValue;
  end;
  PBEHAVIOR_EVENT_PARAMS = ^BEHAVIOR_EVENT_PARAMS;

  GESTURE_CMD =
  (
    GESTURE_REQUEST = 0,
    GESTURE_ZOOM,
    GESTURE_PAN,
    GESTURE_ROTATE,
    GESTURE_TAP1,
    GESTURE_TAP2,
    GESTURE_CMD_DUMMY = MAXINT
  );

  GESTURE_STATE =
  (
    GESTURE_STATE_BEGIN   = 1,
    GESTURE_STATE_INERTIA = 2,
    GESTURE_STATE_END     = 4,
    GESTURE_STATE_DUMMY   = MAXINT
  );

  GESTURE_TYPE_FLAGS =
  (
    GESTURE_FLAG_ZOOM               = $0001,
    GESTURE_FLAG_ROTATE             = $0002,
    GESTURE_FLAG_PAN_VERTICAL       = $0004,
    GESTURE_FLAG_PAN_HORIZONTAL     = $0008,
    GESTURE_FLAG_TAP1               = $0010,
    GESTURE_FLAG_TAP2               = $0020,

    GESTURE_FLAG_PAN_WITH_GUTTER    = $4000,
    GESTURE_FLAG_PAN_WITH_INERTIA   = $8000,
    GESTURE_FLAGS_ALL               = $FFFF,

    GESTURE_TYPE_FLAGS_DUMMY = MAXINT
  );

  GESTURE_PARAMS = record
         cmd  : GESTURE_CMD;
      target  : HELEMENT;
         pos  : TPoint;
     pos_view : TPoint;
        flags : Integer;    // for GESTURE_REQUEST combination of GESTURE_FLAGs.
                            // for others it is a combination of GESTURE_STATe's
   delta_time : UINT;       // period of time from previous event.
     delta_xy : TSize;      // for GESTURE_PAN it is a direction vector
      delta_v : Double;     // for GESTURE_ROTATE - delta angle (radians)
                            // for GESTURE_ZOOM - zoom value, is less or greater than 1.0
  end;
  PGESTURE_PARAMS = ^GESTURE_PARAMS;

  REQUEST_TYPE =
  (
    GET_ASYNC,  // async GET
    POST_ASYNC, // async POST
    GET_SYNC,   // synchronous GET
    POST_SYNC,   // synchronous POST
    REQUEST_TYPE_DUMMY = MAXINT
  );

  OUTPUT_SEVERITY =
  (
    OS_INFO,
    OS_WARNING,
    OS_ERROR,
    OUTPUT_SEVERITY_DUMMY = MAXINT
  );

  SciterWindowDelegate = function(hwnd: HWINDOW; msg: UINT; w: WParam; l: LPARAM; pParam: LPVOID; var pResult: LRESULT): BOOL; stdcall;
  PSciterWindowDelegate = ^SciterWindowDelegate;

  ISciterRAPI = record
    // a.k.a AddRef()
    RequestUse: function(rq: HREQUEST): REQUEST_RESULT; stdcall;
    // a.k.a Release()
    RequestUnUse: function(rq: HREQUEST): REQUEST_RESULT; stdcall;
    // get requested URL
    RequestUrl: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get real, content URL (after possible redirection)
    RequestContentUrl: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get requested data type
    RequestGetRequestType: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get requested data type
    RequestGetRequestedDataType: function(rq: HREQUEST; var pData: SciterResourceType): REQUEST_RESULT; stdcall;
    // get received data type, string, mime type
    RequestGetReceivedDataType: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get number of request parameters passed
    RequestGetNumberOfParameters: function(rq: HREQUEST; var pData: UINT): REQUEST_RESULT; stdcall;
    // get nth request parameter name
    RequestGetNthParameterName: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth request parameter value
    RequestGetNthParameterValue: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get request times , ended - started = milliseconds to get the requst
    RequestGetTimes: function(rq: HREQUEST; var pStarted: UINT; var pEnded: UINT): REQUEST_RESULT; stdcall;
    // get number of request headers
    RequestGetNumberOfRqHeaders: function(rq: HREQUEST; var pNumber: UINT): REQUEST_RESULT; stdcall;
    // get nth request header name
    RequestGetNthRqHeaderName: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth request header value
    RequestGetNthRqHeaderValue: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get number of response headers
    RequestGetNumberOfRspHeaders: function(rq: HREQUEST; var pNumber: UINT): REQUEST_RESULT; stdcall;
    // get nth response header name
    RequestGetNthRspHeaderName: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth response header value
    RequestGetNthRspHeaderValue: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get completion status (CompletionStatus - http response code : 200, 404, etc.)
    RequestGetCompletionStatus: function(rq: HREQUEST; var pState: REQUEST_STATE; var pCompletionStatus: UINT): REQUEST_RESULT; stdcall;
    // get proxy host
    RequestGetProxyHost: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get proxy port
    RequestGetProxyPort: function(rq: HREQUEST; var pPort: UINT): REQUEST_RESULT; stdcall;
    // mark reequest as complete with status and data
    RequestSetSucceeded: function(rq: HREQUEST; status: UINT; dataOrNull: PByte; dataLength: UINT): REQUEST_RESULT; stdcall;
    // mark reequest as complete with failure and optional data
    RequestSetFailed: function(rq: HREQUEST; status: UINT; dataOrNull: PByte; dataLength: UINT): REQUEST_RESULT; stdcall;
    // append received data chunk
    RequestAppendDataChunk: function(rq: HREQUEST; data: PByte; dataLength: UINT): REQUEST_RESULT; stdcall;
    // set request header (single item)
    RequestSetRqHeader: function(rq: HREQUEST; name: PWideChar; value: PWideChar): REQUEST_RESULT; stdcall;
    // set respone header (single item)
    RequestSetRspHeader: function(rq: HREQUEST; name: PWideChar; value: PWideChar): REQUEST_RESULT; stdcall;
    // set received data type, string, mime type
    RequestSetReceivedDataType: function(rq: HREQUEST; rqType: PAnsiChar): REQUEST_RESULT; stdcall;
    // set received data encoding, string
    RequestSetReceivedDataEncoding: function(rq: HREQUEST; encoding: PAnsiChar): REQUEST_RESULT; stdcall;
    // get received (so far) data
    RequestGetData: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
  end;

  PSciterRApi = ^ISciterRAPI;
  SciterRApiFunc = function: PSciterRApi; stdcall;
  PSciterRApiFunc = ^SciterRApiFunc;

  ISciterAPI = record
    Version: UINT;
    SciterClassName: function: LPCWSTR; stdcall;
    SciterVersion: function(major: BOOL): UINT; stdcall;
    SciterDataReady: function(hwnd: HWINDOW; uri: PWideChar; data: PByte; dataLength: UINT): BOOL; stdcall;
    SciterDataReadyAsync: function(hwnd: HWINDOW; uri: PWideChar; data: PByte; dataLength: UINT; requestId: LPVOID): BOOL; stdcall;
    SciterProc: function(hwnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
    SciterProcND: function(hwnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHANDLED: BOOL): LRESULT; stdcall;
    SciterLoadFile: function(hWndSciter: HWINDOW; filename:LPCWSTR): BOOL; stdcall;
    SciterLoadHtml: function(hWndSciter: HWINDOW; html: PByte; htmlSize: UINT; baseUrl: PWideChar): BOOL; stdcall;
    SciterSetCallback: procedure(hWndSciter: HWINDOW; cb: LPSciterHostCallback; cbParam: Pointer); stdcall;
    SciterSetMasterCSS: function(utf: PAnsiChar; numBytes: UINT): BOOL; stdcall;
    SciterAppendMasterCSS: function(utf: PAnsiChar; numBytes: UINT): BOOL; stdcall;
    SciterSetCSS: function(hWndSciter: HWindow; utf8: PAnsiChar; numBytes: UINT; baseUrl: PWideChar; mediaType: PWideChar): BOOL; stdcall;
    SciterSetMediaType: function(hWndSciter: HWINDOW; mediaTYpe: PWideChar): BOOL; stdcall;
    SciterSetMediaVars: function(hWndSciter: HWINDOW; const mediaVars: PSciterValue): BOOL; stdcall;
    SciterGetMinWidth: function(hwnd: HWINDOW): UINT; stdcall;
    SciterGetMinHeight: function(hwnd: HWINDOW; width: UINT): UINT; stdcall;
    SciterCall: function(hWnd: HWINDOW; functionName: PAnsiChar; argc: UINT; const argv: PSciterValue; var retval: TSciterValue): BOOL; stdcall;
    SciterEval: function(hwnd: HWINDOW; script: PWideChar; scriptLength: UINT; var retval: TSciterValue): BOOL; stdcall;
    SciterUpdateWindow: procedure(hwnd: HWINDOW); stdcall;
    SciterTranslateMessage: function(var lpMsg: TMsg): BOOL; stdcall;
    SciterSetOption: function(hwnd: HWINDOW; option: SCITER_RT_OPTIONS; value: UINT_PTR): BOOL; stdcall;
    SciterGetPPI: procedure(hWndSciter: HWINDOW; var px: UINT; var py: UINT); stdcall;
    SciterGetViewExpando: function(hwnd: HWINDOW; var pval: TSciterValue): BOOL; stdcall;
    SciterRenderD2D: TProcPointer;
    SciterD2DFactory: TProcPointer;
    SciterDWFactory: TProcPointer;
    SciterGraphicsCaps: function(var pcaps: UINT): BOOL; stdcall;
    SciterSetHomeURL: function(hWndSciter: HWINDOW; baseUrl: PWideChar): BOOL; stdcall;
    SciterCreateWindow: function(creationFlags: UINT; var frame: TRect; delegate: PSciterWindowDelegate; delegateParam: LPVOID; parent: HWINDOW): HWINDOW; stdcall;
    SciterSetupDebugOutput: procedure(hwndOrNull: HWINDOW; param: Pointer; pfOutput: PDEBUG_OUTPUT_PROC); stdcall;

//|
//| DOM Element API
//|

    Sciter_UseElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    Sciter_UnuseElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetRootElement: function(hwnd: HWINDOW; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetFocusElement: function(hwnd: HWINDOW; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterFindElement: function(hwnd: HWINDOW; Point: TPoint; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetChildrenCount: function(he: HELEMENT; var count: UINT): SCDOM_RESULT; stdcall;
    SciterGetNthChild: function(he: HELEMENT; index: UINT; var retval: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetParentElement: function(he: HELEMENT; var p_parent_he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementHtmlCB: function(he: HELEMENT; Outer: BOOL; Callback: PLPCBYTE_RECEIVER; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterGetElementTextCB: function(he: HELEMENT; callback: PLPCWSTR_RECEIVER; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetElementText: function(he: HELEMENT; Value: PWideChar; Len: UINT): SCDOM_RESULT; stdcall;
    SciterGetAttributeCount: function(he: HELEMENT; var Count: UINT): SCDOM_RESULT; stdcall;
    SciterGetNthAttributeNameCB: function(he: HELEMENT; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; stdcall;
    SciterGetNthAttributeValueCB: function(he: HELEMENT; n: UINT; rcv: PLPCWSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; stdcall;
    SciterGetAttributeByNameCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetAttributeByName: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterClearAttributes: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementIndex: function(he: HELEMENT; var p_index: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementType: function(he: HELEMENT; var s: LPCSTR): SCDOM_RESULT; stdcall;
    SciterGetElementTypeCB: function(he: HELEMENT; rcv: PLPCSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterGetStyleAttributeCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetStyleAttribute: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterGetElementLocation: function(he: HELEMENT; var p_location: TRect; areas: ELEMENT_AREAS): SCDOM_RESULT; stdcall;
    SciterScrollToView: function(he: HELEMENT; SciterScrollFlags: UINT): SCDOM_RESULT; stdcall;
    SciterUpdateElement: function(he: HELEMENT; andForceRender: BOOL): SCDOM_RESULT; stdcall;
    SciterRefreshElementArea: function(he: HELEMENT; rc: TRect): SCDOM_RESULT; stdcall;
    SciterSetCapture: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterReleaseCapture: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementHwnd: function(he: HELEMENT; var p_hwnd: HWINDOW; rootWindow: BOOL): SCDOM_RESULT; stdcall;
    SciterCombineURL: function(he: HELEMENT; szUrlBuffer: PWideChar; UrlBufferSize: UINT): SCDOM_RESULT; stdcall;
    SciterSelectElements: function(he: HELEMENT; CSS_selectors: PAnsiChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectElementsW: function(he: HELEMENT; CSS_selectors: PWideChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectParent: function(he: HELEMENT; selector: PAnsiChar; depth: UINT; var heFound: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSelectParentW: function(he: HELEMENT; selector: PWideChar; depth: UINT; var heFound: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetElementHtml: function(he: HELEMENT; html: PByte; htmlLength: UINT; where: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementUID: function(he: HELEMENT; var puid: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementByUID: function(hwnd: HWINDOW; uid: UINT; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterShowPopup: function(popup: HELEMENT; Anchor: HELEMENT; placement: UINT): SCDOM_RESULT; stdcall;
    SciterShowPopupAt: function(Popup: HELEMENT; pos: TPoint; animate: BOOL): SCDOM_RESULT; stdcall;
    SciterHidePopup: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementState: function(he: HELEMENT; var pstateBits: UINT): SCDOM_RESULT; stdcall;
    SciterSetElementState: function(he: HELEMENT; stateBitsToSet: UINT; stateBitsToClear: UINT; updateView: BOOL): SCDOM_RESULT; stdcall;
    SciterCreateElement: function(const tagname: PAnsiChar; const textOrNull: PWideChar; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterCloneElement: function(he: HELEMENT; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterInsertElement: function(he: HELEMENT; hparent: HELEMENT; index: UINT): SCDOM_RESULT; stdcall;
    SciterDetachElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterDeleteElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetTimer: function(he: HELEMENT; milliseconds: UINT; var timer_id: UINT): SCDOM_RESULT; stdcall;
    SciterDetachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterAttachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterWindowAttachEventHandler: function(hwndLayout: HWINDOW; pep: LPELEMENT_EVENT_PROC; tag: LPVOID; subscription: UINT): SCDOM_RESULT; stdcall;
    SciterWindowDetachEventHandler: function(hwndLayout: HWINDOW; pep: LPELEMENT_EVENT_PROC; tag: LPVOID): SCDOM_RESULT; stdcall;
    SciterSendEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT; var handled: BOOL): SCDOM_RESULT; stdcall;
    SciterPostEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT): SCDOM_RESULT; stdcall;
    SciterCallBehaviorMethod: function(he: HELEMENT; params: PMETHOD_PARAMS): SCDOM_RESULT; stdcall;
    SciterRequestElementData: function(he: HELEMENT; url: PWideChar; dataType: UINT; initiator: HELEMENT): SCDOM_RESULT; stdcall;
    SciterHttpRequest: function(he: HELEMENT; url: PWideChar; dataType: UINT;
      requestType: REQUEST_TYPE; requestParams: PREQUEST_PARAM;
      nParams: UINT): SCDOM_RESULT; stdcall;
    SciterGetScrollInfo: function(he: HELEMENT; var scrollPos: TPoint; var viewRect:TRect; var contentSize: TSize): SCDOM_RESULT; stdcall;
    SciterSetScrollPos: function(he: HELEMENT; scrollPos: TPoint; smooth: BOOL): SCDOM_RESULT; stdcall;
    SciterGetElementIntrinsicWidths: function(he: HELEMENT; var pMinWidth: integer; var pMaxWidth: integer): SCDOM_RESULT; stdcall;
    SciterGetElementIntrinsicHeight: function(he: HELEMENT; forWidth: Integer; var pHeight: integer): SCDOM_RESULT; stdcall;
    SciterIsElementVisible: function(he: HELEMENT; var pVisible: BOOL): SCDOM_RESULT; stdcall;
    SciterIsElementEnabled: function(he: HELEMENT; var pEnabled: BOOL): SCDOM_RESULT; stdcall;
    SciterSortElements: TProcPointer;
    SciterSwapElements: function(he1: HELEMENT; he2: HELEMENT): SCDOM_RESULT; stdcall;
    SciterTraverseUIEvent: function(evt: UINT; eventCtlStruct: LPVOID ; var bOutProcessed: BOOL): SCDOM_RESULT; stdcall;
    SciterCallScriptingMethod: function(he: HELEMENT; name: PAnsiChar; const argv: PSciterValue; argc: UINT; var retval: TSciterValue): SCDOM_RESULT; stdcall;
    SciterCallScriptingFunction: function(he: HELEMENT; name: PAnsiChar; const argv: PSciterValue; argc: UINT; var retval: TSciterValue): SCDOM_RESULT; stdcall;
    SciterEvalElementScript: function(he: HELEMENT; script: PWideChar; scriptLength: UINT; var retval: TSciterValueType): SCDOM_RESULT; stdcall;
    SciterAttachHwndToElement: function(he: HELEMENT; hwnd: HWINDOW): SCDOM_RESULT; stdcall;
    SciterControlGetType: TProcPointer;
    SciterGetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;  
    SciterSetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;
    SciterGetExpando: TProcPointer;
    SciterGetObject: function(he: HELEMENT; var pval: tiscript_value; forceCreation: BOOL): SCDOM_RESULT; stdcall;
    SciterGetElementNamespace: function(he: HELEMENT; var pval: tiscript_value): SCDOM_RESULT; stdcall;
    SciterGetHighlightedElement: function(h: HWINDOW; var he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetHighlightedElement: function(h: HWINDOW; he: HELEMENT): SCDOM_RESULT; stdcall;

    SciterNodeAddRef: TProcPointer;
    SciterNodeRelease: TProcPointer;
    SciterNodeCastFromElement: TProcPointer;
    SciterNodeCastToElement: TProcPointer;
    SciterNodeFirstChild: TProcPointer;
    SciterNodeLastChild: TProcPointer;
    SciterNodeNextSibling: TProcPointer;
    SciterNodePrevSibling: TProcPointer;
    SciterNodeParent: TProcPointer;
    SciterNodeNthChild: TProcPointer;
    SciterNodeChildrenCount: TProcPointer;
    SciterNodeType: TProcPointer;
    SciterNodeGetText: TProcPointer;
    SciterNodeSetText: TProcPointer;
    SciterNodeInsert: TProcPointer;
    SciterNodeRemove: TProcPointer;
    SciterCreateTextNode: TProcPointer;
    SciterCreateCommentNode: TProcPointer;

    ValueInit: function(Value: PSciterValue): UINT; stdcall;
    ValueClear: function(Value: PSciterValue): UINT; stdcall;
    ValueCompare: function(Value1: PSciterValue; Value2: PSciterValue): UINT; stdcall;
    ValueCopy: function(dst: PSciterValue; src: PSciterValue): UINT; stdcall;
    ValueIsolate: function(Value: PSciterValue): UINT; stdcall;
    ValueType: function(Value: PSciterValue; var pType: TSciterValueType; var pUnits: UINT): UINT; stdcall;
    ValueStringData: function(Value: PSciterValue; var Chars: PWideChar; var NumChars: UINT): UINT; stdcall;
    ValueStringDataSet: function(Value: PSciterValue; Chars: PWideChar; NumChars: UINT; Units: UINT): UINT; stdcall;
    ValueIntData: function(Value: PSciterValue; var pData: Integer): UINT; stdcall;
    ValueIntDataSet:function(Value: PSciterValue; data: Integer; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueInt64Data: function(Value: PSciterValue; var pData: Int64): UINT; stdcall;
    ValueInt64DataSet: function(Value: PSciterValue; data: Int64; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueFloatData: function(Value: PSciterValue; var pData: double): UINT; stdcall;
    ValueFloatDataSet: function(Value: PSciterValue; data: double; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueBinaryData: function(Value: PSciterValue; var bytes: PByte; var pnBytes: UINT): UINT; stdcall; 
    ValueBinaryDataSet: function(Value: PSciterValue; bytes: PByte; nBytes: UINT; pType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueElementsCount: function(Value: PSciterValue; var pData: UINT): UINT; stdcall;
    ValueNthElementValue: function(Value: PSciterValue; n: Integer; var retval: TSciterValue): UINT; stdcall;
    ValueNthElementValueSet: function(pval: PSciterValue; n: Integer; pval_to_set: PSciterValue): UINT; stdcall;
    ValueNthElementKey: function(Value: PSciterValue; n: Integer; var retval: TSciterValue): UINT; stdcall;
    ValueEnumElements: function(Value: PSciterValue; penum, param: Pointer): UINT; stdcall;
    ValueSetValueToKey: function(Value: PSciterValue; const pKey: PSciterValue; const pValToSte: PSciterValue): UINT; stdcall;
    ValueGetValueOfKey: function(Value: PSciterValue; const pKey: PSciterValue; var retval: TSciterValue): UINT; stdcall;
    ValueToString: function(Value: PSciterValue; How: VALUE_STRING_CVT_TYPE): UINT; stdcall;
    ValueFromString: function(Value: PSciterValue; str: PWideChar; strLength: UINT; how: VALUE_STRING_CVT_TYPE): UINT; stdcall;
    ValueInvoke: function(Value: PSciterValue; this: PSciterValue; argc: UINT; const agrv: PSciterValue; var retval: TSciterValue; url: LPCWSTR): UINT; stdcall;
    ValueNativeFunctorSet: function(Value: PSciterValue; pinvoke, prelease, tag: Pointer): UINT; stdcall;
    ValueIsNativeFunctor: TProcPointer;

    // tiscript VM API
    TIScriptAPI: function: ptiscript_native_interface; stdcall;

    SciterGetVM: function(h: HWND): HVM; stdcall;

    // Sciter_v2V
    Sciter_T2S: function(vm: HVM; script_value: tiscript_value; var sciter_value: TSciterValue; isolate: BOOL): BOOL; stdcall;
    Sciter_S2T: function(vm: HVM; value: PSciterValue; var out_script_value: tiscript_value): BOOL; stdcall;

    SciterOpenArchive: function(archiveData: PByte; archiveDataLength: UINT): HSARCHIVE; stdcall;
    SciterGetArchiveItem: procedure(harc: HSARCHIVE; path: PWideChar; var pdata: PByte; var pdataLength: UINT); stdcall;
    SciterCloseArchive: procedure(harc: HSARCHIVE); stdcall;

    SciterFireEvent: function(var evt: BEHAVIOR_EVENT_PARAMS; post: BOOL; var handled: BOOL): SCDOM_RESULT; stdcall;

    SciterGetCallbackParam: TProcPointer;
    SciterPostCallback: TProcPointer;

//    GetSciterGraphicsAPI: TProcPointer;
    GetSciterRequestAPI: SciterRApiFunc;

//    SciterCreateOnDirectXWindow: function(hwnd: HWINDOW; var pSwapChain: IDXGISwapChain): BOOL; stdcall;
//    SciterRenderOnDirectXWindow: function(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; frontLayer: BOOL): BOOL; stdcall;
//    SciterRenderOnDirectXTexture: function(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; var surface: IDXGISurface): BOOL; stdcall;
  end;

  PSciterApi = ^ISciterAPI;
  SciterApiFunc = function: PSciterApi; stdcall;
  PSciterApiFunc = ^SciterApiFunc;

  INITIALIZATION_EVENTS =
  (
    BEHAVIOR_DETACH = 0,
    BEHAVIOR_ATTACH = 1,
    INITIALIZATION_EVENTS_DUMMY = MAXINT
  );


  INITIALIZATION_PARAMS = record
    cmd: INITIALIZATION_EVENTS;
  end;
  PINITIALIZATION_PARAMS = ^INITIALIZATION_PARAMS;


  KEYBOARD_STATES =
  (
    CONTROL_KEY_PRESSED = 1,
    SHIFT_KEY_PRESSED = 2,
    ALT_KEY_PRESSED = 4,
    KEYBOARD_STATES_DUMMY = MAXINT
  );


  CURSOR_TYPE =
  (
    CURSOR_ARROW,
    CURSOR_IBEAM,
    CURSOR_WAIT,
    CURSOR_CROSS,
    CURSOR_UPARROW,
    CURSOR_SIZENWSE,
    CURSOR_SIZENESW,
    CURSOR_SIZEWE,
    CURSOR_SIZENS,
    CURSOR_SIZEALL,
    CURSOR_NO,
    CURSOR_APPSTARTING,
    CURSOR_HELP,
    CURSOR_HAND,
    CURSOR_DRAG_MOVE,
    CURSOR_DRAG_COPY,
    CURSOR_OTHER,
    CURSOR_TYPE_DUMMY = MAXINT
  );


  MOUSE_EVENTS =
  (
    MOUSE_EVENTS_ALL = -1,          // doesn't exist in sciter api, used to define null event
    MOUSE_ENTER  = 0,
    MOUSE_LEAVE  = 1,
    MOUSE_MOVE   = 2,
    MOUSE_UP     = 3,
    MOUSE_DOWN   = 4,
    MOUSE_DCLICK = 5,
    MOUSE_WHEEL  = 6,
    MOUSE_TICK   = 7,
    MOUSE_IDLE   = 8,
    DROP         = 9,
    DRAG_ENTER   = 10,
    DRAG_LEAVE   = 11,
    DRAG_REQUEST = 12,
    MOUSE_CLICK  = $FF,
    DRAGGING     = $100,
    MOUSE_EVENTS_DUMMY = MAXINT // doesn't exist in sciter api, used for sizeof(uint) alignment
  );


  MOUSE_BUTTONS =
  (
    MAIN_MOUSE_BUTTON    = 1,
    PROP_MOUSE_BUTTON    = 2,
    MIDDLE_MOUSE_BUTTON  = 4,
    MOUSE_BUTTONS_DUMMY  = MAXINT
  );


  MOUSE_PARAMS = record
             cmd: MOUSE_EVENTS;
          target: HELEMENT;
             pos: TPoint;
        pos_view: TPoint;
    button_state: MOUSE_BUTTONS;
       alt_state: KEYBOARD_STATES;
     cursor_type: CURSOR_TYPE;
      is_on_icon: BOOL;
        dragging: HELEMENT;
   dragging_mode: UINT;
  end;
  PMOUSE_PARAMS = ^MOUSE_PARAMS;


  KEY_EVENTS =
  (
    KEY_EVENTS_ALL = -1,      // doesn't exist in sciter api, used to define null event
    KEY_DOWN = 0,
    KEY_UP,
    KEY_CHAR,
    KEY_EVENTS_DUMMY = MAXINT // doesn't exist in sciter api, used for sizeof(uint) alignment
  );

  KEY_PARAMS = record
          cmd: KEY_EVENTS;
       target: HELEMENT;
     key_code: UINT;
    alt_state: KEYBOARD_STATES;
  end;
  PKEY_PARAMS = ^KEY_PARAMS;


  FOCUS_EVENTS =
  (
    LOST_FOCUS,
    GOT_FOCUS,
    FOCUS_EVENTS_DUMMY = MAXINT
  );


  FOCUS_PARAMS = record
               cmd: FOCUS_EVENTS;
            target: HELEMENT;
    by_mouse_click: BOOL;
            cancel: BOOL;
  end;
  PFOCUS_PARAMS = ^FOCUS_PARAMS;


  DATA_ARRIVED_PARAMS = record
    initiator: HELEMENT;
         data: PByte;
     dataSize: UINT;
     dataType: UINT;
       status: UINT;
          uri: PWideChar;
  end;
  PDATA_ARRIVED_PARAMS = ^DATA_ARRIVED_PARAMS;

  DRAW_EVENTS =
  (
      DRAW_BACKGROUND = 0,
      DRAW_CONTENT = 1,
      DRAW_FOREGROUND = 2,
      DRAW_EVENTS_DUMMY = MAXINT
  );

  DRAW_PARAMS = record
    cmd: DRAW_EVENTS;
    hdc: HDC;
    area: TRect;
    reserved: UINT;
  end;
  PDRAW_PARAMS=^DRAW_PARAMS;


  TIMER_PARAMS = record
    timerId: UINT_PTR;
  end;
  PTIMER_PARAMS = ^TIMER_PARAMS;


  SCRIPTING_METHOD_PARAMS = record
    name: PAnsiChar;
    argv: PSciterValue; // SCITER_VALUE*
    argc: UINT;
    rv: TSciterValue;
  end;
  PSCRIPTING_METHOD_PARAMS = ^SCRIPTING_METHOD_PARAMS;


  TISCRIPT_METHOD_PARAMS = record
    vm: HVM;
    tag: tiscript_value;
    result: tiscript_value;
  end;
  PTISCRIPT_METHOD_PARAMS = ^TISCRIPT_METHOD_PARAMS;


  SCROLL_EVENTS =
  (
    SCROLL_HOME,
    SCROLL_END,
    SCROLL_STEP_PLUS,
    SCROLL_STEP_MINUS,
    SCROLL_PAGE_PLUS,
    SCROLL_PAGE_MINUS,
    SCROLL_POS,
    SCROLL_SLIDER_RELEASED,
    SCROLL_CORNER_PRESSED,
    SCROLL_CORNER_RELEASED,
    SCROLL_EVENTS_DUMMY = MAXINT
  );

  SCROLL_PARAMS = record
    cmd: SCROLL_EVENTS;
    target: HELEMENT;
    pos: integer;
    vertical: BOOL;
  end;
  PSCROLL_PARAMS = ^SCROLL_PARAMS;

  { Inspector }
  TSciterInspector = procedure(root: HELEMENT; papi: PSciterApi); stdcall;
  TSciterWindowInspector = procedure(hwndSciter: HWINDOW; papi: PSciterApi); stdcall;

  { Exceptions }
  ESciterException = class(Exception)
  end;

  ESciterNullPointerException = class(ESciterException)
  public
    constructor Create;
  end;

  ESciterCallException = class(ESciterException)
  public
    constructor Create(const MethodName: String);
  end;

  ESciterNotImplementedException = class(ESciterException)
  end;

  TRecordData = class(TPersistent)
  public
    RecObj: Pointer;
    RecType: Pointer;
  end;

  TRecordVarData = packed record
    VType: TVarType;
    Reserved1, Reserved2, Reserved3: Word;
    VRecord: TRecordData;
    Reserved4: NativeInt;
  end;

  TRecordVariantType = class(TCustomVariantType)
  public
    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean); override;
    procedure Clear(var V: TVarData); override;
    function IsClear(const V: TVarData): Boolean; override;
  end;

{ Conversion functions. Mnemonics are: T - tiscript_value, S - TSciterValue, V - VARIANT }
function S2V(Value: PSciterValue; var OutValue: Variant): UINT;
function V2S(const Value: Variant; SciterValue: PSciterValue): UINT;
function T2V(const vm: HVM; Value: tiscript_value): Variant;
function V2T(const vm: HVM; const Value: Variant): tiscript_value;

function API: PSciterApi;
function RAPI: PSciterRApi;
function NI: ptiscript_native_interface;
function IsNameExists(const vm: HVM; ns: tiscript_value; const Name: WideString): boolean;
function IsNativeClassExists(const vm: HVM; const Name: WideString): boolean;
function GetNativeObject(const vm: HVM; const Name: WideString): tiscript_value;
function GetNativeClass(const vm: HVM; const ClassName: WideString): tiscript_class;
function RegisterNativeFunction(const vm: HVM; ns: tiscript_value; const Name: WideString; Handler: Pointer; ThrowIfExists: Boolean = False; tag: Pointer = nil): Boolean;
function RegisterNativeClass(const vm: HVM; ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean): tiscript_class;
function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: tiscript_class): tiscript_object; overload;
function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: WideString): tiscript_object; overload;
procedure RegisterObject(const vm: HVM; Obj: tiscript_object; const VarName: WideString); overload;
procedure RegisterObject(const vm: HVM; Obj: Pointer; const OfClass: WideString; const VarName: WideString); overload;
function SciterVarType(value: PSciterValue): TSciterValueType;
function SciterVarToString(value: PSciterValue): WideString;
procedure ThrowError(const vm: HVM; const Message: AnsiString); overload;
procedure ThrowError(const vm: HVM; const Message: WideString); overload;
function GetNativeObjectJson(const Value: PSciterValue): WideString;

var
  SCITER_DLL_DIR: String = '';
  varRecordEx: Word = 0;

implementation

var
  FAPI: PSciterApi;
  FRAPI: PSciterRApi;
  FNI: ptiscript_native_interface;
  HSCITER: HMODULE;
  RecordVariantType: TRecordVariantType;

{ TRecordVariantType }

procedure TRecordVariantType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  with TRecordVarData(Dest) do
  begin
    VType := VarType;
    VRecord := TRecordData.Create;
    VRecord.RecObj := TRecordVarData(Source).VRecord.RecObj;
    VRecord.RecType := TRecordVarData(Source).VRecord.RecType;
  end;
end;

procedure TRecordVariantType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
  FreeAndNil(TRecordVarData(V).VRecord);
end;

function TRecordVariantType.IsClear(const V: TVarData): Boolean;
begin
  Result := not Assigned(TRecordVarData(V).VRecord);
end;

function GetNativeObjectJson(const Value: PSciterValue): WideString;
var
  pWStr: PWideChar;
  iNum: UINT;
  pType: TSciterValueType;
  pUnits: UINT;
begin
  pUnits := 0;
  API.ValueType(Value, pType, pUnits);
  if (pType = T_NULL) or (pType = T_UNDEFINED) then
  begin
    Result := '';
    Exit;
  end;
  
  API.ValueToString(Value, CVT_XJSON_LITERAL);
  API.ValueStringData(Value, pWStr, iNum);
  Result := WideString(pWstr);
end;

function NI: ptiscript_native_interface;
begin
  if FNI = nil then
  begin
    if FAPI = nil then
      raise ESciterException.Create('Sciter DLL is not loaded.');
    FNI := FAPI.TIScriptAPI;
  end;
  Result := FNI;
end;

procedure ThrowError(const vm: HVM; const Message: AnsiString);
begin
  NI.throw_error(vm, PWideChar(WideString(Message)));
end;

procedure ThrowError(const vm: HVM; const Message: WideString);
begin
  NI.throw_error(vm, PWideChar(Message));
end;

function IsNativeClassExists(const vm: HVM; const Name: WideString): boolean;
var
  var_name: tiscript_string;
  var_value: tiscript_object;
  zns: tiscript_value;
begin
  Result := False;

  zns := NI.get_global_ns(vm);
  var_name := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  
  if NI.is_class(vm, var_value) then
    Result := True;
end;

{ Returns true if an object (class, variable, constant etc) exists in local or global namespace, false otherwise }
function IsNameExists(const vm: HVM; ns: tiscript_value; const Name: WideString): boolean;
var
  var_name, var_value, zns: tiscript_value;
begin
  if ns = 0 then
    zns := NI.get_global_ns(vm)
  else
    zns := ns;

  var_name := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  Result := not NI.is_undefined(var_value);
end;

function GetNativeObject(const vm: HVM; const Name: WideString): tiscript_value;
var
  var_name: tiscript_string;
  var_value: tiscript_object;
  zns: tiscript_value;
begin
  zns := NI.get_global_ns(vm);
  var_name := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  Result := var_value;
end;

{ Returns tiscript value of type "class" }
function GetNativeClass(const vm: HVM; const ClassName: WideString): tiscript_class;
var
  zns: tiscript_value;
  tclass_name: tiscript_string;
  class_def: tiscript_class;
begin
  zns := NI.get_global_ns(vm);
  tclass_name := NI.string_value(vm, PWideChar(ClassName), Length(ClassName));
  class_def := NI.get_prop(vm, zns, tclass_name);
  if NI.is_class(vm, class_def) then
    Result := class_def
  else
    Result := NI.undefined_value;
end;

{ Returns true if a function registration was successfull,
  false if a function with same name was already registered,
  throws an exception otherwise }
function RegisterNativeFunction(const vm: HVM; ns: tiscript_value; const Name: WideString; Handler: Pointer; ThrowIfExists: Boolean = False; tag: Pointer = nil): Boolean;
var
  method_def: ptiscript_method_def;
  smethod_name: AnsiString;
  func_def, func_name, zns: tiscript_value;
begin
  if IsNameExists(vm, ns, Name) and ThrowIfExists then
    raise ESciterException.CreateFmt('Failed to register native function %s. Object with same name already exists.', [Name]);
    
  if ns = 0 then
    zns := NI.get_global_ns(vm)
  else
    zns := ns;

  smethod_name := AnsiString(Name);
  func_name := NI.string_value(vm, PWideChar(Name), Length(Name));
  func_def := NI.get_prop(vm, zns, func_name);

  if NI.is_undefined(func_def) then
  begin
    New(method_def); // record leaks!
    method_def.dispatch := nil;
    method_def.name := PAnsiChar(smethod_name);
    method_def.handler := Handler;
    method_def.tag := tag;
    method_def.payload := 0;
    func_def := NI.native_function_value(vm, method_def);
    if not NI.is_native_function(func_def) then
      raise Exception.CreateFmt('Failed to register native function "%s".', [Name]);
    NI.set_prop(vm, zns, func_name, func_def);
    Result := True;
  end
    else
  if NI.is_native_function(func_def) then
    Result := False
  else
    raise ESciterException.CreateFmt('Cannot register native function "%s" (unexpected error). Seems that object with same name already exists.', [Name]);
end;

function RegisterNativeClass(const vm: HVM; ClassDef: ptiscript_class_def; ThrowIfExists: Boolean; ReplaceClassDef: Boolean): tiscript_class;
var
  zns: tiscript_value;
  wclass_name: WideString;
  tclass_name: tiscript_string;
  class_def: tiscript_class;
begin
  zns := NI.get_global_ns(vm);

  wclass_name := WideString(AnsiString(ClassDef.name));
  tclass_name := NI.string_value(vm, PWideChar(wclass_name), Length(wclass_name));
  class_def := NI.get_prop(vm, zns, tclass_name);

  if NI.is_undefined(class_def) then
  begin
    class_def := NI.define_class(vm, ClassDef, zns);
    if not NI.is_class(vm, class_def) then
      raise ESciterException.CreateFmt('Failed to register class definition.', []);
    Result := class_def;
  end
    else
  if NI.is_class(vm, class_def) then
  begin
    if ThrowIfExists then
    begin
      raise ESciterException.CreateFmt('Class "%s" already exists.', [String(ClassDef.name)]);
    end
      else
    begin
      Result := class_def;
    end;
  end
    else
  begin
    raise ESciterException.CreateFmt('Failed to register native class "%s". Object with same name (class, namespace, constant, variable or function) already exists.', [String(ClassDef.name)]);
  end;
end;

function SciterVarType(value: PSciterValue): TSciterValueType;
var
  pUnits: UINT;
begin
  API.ValueType(value, Result, pUnits);
end;

function SciterVarToString(value: PSciterValue): WideString;
var
  pCh: PWideChar;
  iNum: UINT;
begin
  API.ValueStringData(value, pCh, iNum);
  Result := WideString(pCh);
end;

function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: tiscript_class): tiscript_object;
begin
  if not NI.is_class(vm, OfClass) then
    raise ESciterException.CreateFmt('Cannot create object instance. Provided value is not a class.', []);
  Result := NI.create_object(vm, OfClass);
  NI.set_instance_data(Result, Obj);
end;

function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: WideString): tiscript_object;
var
  t_class: tiscript_class;
begin
  t_class := GetNativeClass(vm, OfClass);
  Result := CreateObjectInstance(vm, Obj, t_class);
end;

procedure RegisterObject(const vm: HVM; Obj: tiscript_object; const VarName: WideString);
var
  zns: tiscript_value;
  var_name: tiscript_value;
begin
  if not NI.is_native_object(Obj) then
    raise ESciterException.CreateFmt('Cannot register object instance. Provided value is not an object.', []);

  // If a variable VarName already exists it'll be rewritten
  var_name := NI.string_value(vm, PWideChar(VarName), Length(VarName));
  zns := NI.get_global_ns(vm);
  NI.set_prop(vm, zns, var_name, Obj);
end;

procedure RegisterObject(const vm: HVM; Obj: Pointer; const OfClass: WideString; const VarName: WideString); overload;
var
  o: tiscript_value;
begin
  o := CreateObjectInstance(vm, Obj, OfClass);
  RegisterObject(vm, o, VarName);
end;

function API: PSciterApi;
var
  pFuncPtr: SciterApiFunc;
begin
  if FAPI = nil then
  begin
    HSCITER := LoadLibrary(PWideChar(SCITER_DLL_DIR + 'sciter.dll'));
    if HSCITER = 0 then
      raise ESciterException.Create('Failed to load Sciter DLL.');

    pFuncPtr := GetProcAddress(HSCITER, 'SciterAPI');
    if pFuncPtr = nil then
      raise ESciterException.Create('Failed to get pointer to SciterAPI function.');

    FAPI := pFuncPtr();
  end;
  Result := FAPI;
end;

function RAPI: PSciterRApi;
begin
  if FRAPI = nil then
    FRAPI := API.GetSciterRequestAPI();
  Result := FRAPI;
end;

{ SciterValue to Variant conversion }
function S2V(Value: PSciterValue; var OutValue: Variant): UINT;
var
  pType: TSciterValueType;
  pUnits: UINT;
  pWStr: PWideChar;
  iNum: UINT;
  sWStr: WideString;
  iResult: Integer;
  dResult: Double;
  i64Result: Int64;
  ft: TFileTime;
  pbResult: PByte;
  cResult: Currency;
  st: SYSTEMTIME;
  pDispValue: IDispatch;
  arrSize: UINT;
  sArrItem: TSciterValue;
  oArrItem: Variant;
  j: Integer;
begin
  if API.ValueType(Value, pType, pUnits) <> HV_OK then
    raise ESciterException.Create('Unknown Sciter value type.');
  case pType of
    T_ARRAY:
      begin
        API.ValueElementsCount(Value, arrSize);
        OutValue := VarArrayCreate([0, arrSize], varVariant);
        for j := 0 to arrSize - 1 do
        begin
          oArrItem := Unassigned;
          API.ValueInit(@sArrItem);
          API.ValueNthElementValue(Value, j, sArrItem);
          S2V(@sArrItem, oArrItem);
          API.ValueClear(@sArrItem);
          VarArrayPut(Variant(OutValue), oArrItem, [j]);
        end;
        Result := HV_OK;
      end;
    T_BOOL:
      begin
        Result := API.ValueIntData(Value, iResult);
        if Result = HV_OK then
          OutValue := iResult <> 0
        else
          OutValue := False;
      end;
    T_BYTES:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_BYTES to Variant (not implemented).', []);
      end;
    T_CURRENCY:
      begin
        // TODO: ?
        Result := API.ValueInt64Data(Value, i64Result);
        cResult := PCurrency(@i64Result)^;
        OutValue := cResult;
      end;
    T_DATE:
      begin
        Result := API.ValueInt64Data(Value, i64Result);
        ft := TFileTime(i64Result);
        FileTimeToSystemTime(ft, st);
        SystemTimeToVariantTime(st, dResult);
        OutValue := TDateTime(dResult);
      end;
    T_DOM_OBJECT:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_DOM_OBJECT to Variant (not implemented).', []);
      end;
    T_FLOAT:
      begin
        Result := API.ValueFloatData(Value, dResult);
        OutValue := dResult;
      end;
    T_STRING:
      begin
        Result := API.ValueStringData(Value, pWStr, iNum);
        sWStr := WideString(pWStr);
        OutValue := sWStr;
      end;
    T_MAP:
      begin
        OutValue := GetNativeObjectJson(Value);
        Result := HV_OK;
      end;
    T_FUNCTION:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_FUNCTION to Variant (not implemented).', []);
      end;
    T_INT:
      begin
        Result := API.ValueIntData(Value, iResult);
        OutValue := iResult;
      end;
    T_LENGTH:
      begin
        raise ESciterNotImplementedException.CreateFmt('Cannot convert T_LENGTH to Variant (not implemented).', []);
      end;
    
    T_NULL:
      begin
        OutValue := Null;
        Result := HV_OK;
      end;
    T_OBJECT:
      // TODO: returns Variant if Object wraps IDispatch, JSON otherwise
      begin
        pbResult := nil;
        Result := API.ValueBinaryData(Value, pbResult, iNum);
        if Result = HV_OK then
        begin
          if pbResult <> nil then
          begin
            pDispValue := IDispatch(Pointer(pbResult));
            try
              pDispValue._AddRef;
              pDispValue._Release;
              OutValue := OleVariant(pDispValue);
            except
              // not an IDispatch, probably native tiscript object
              OutValue := GetNativeObjectJson(Value);
              Result := HV_OK;
            end;
          end
            else
          begin
            OutValue := Unassigned;
          end;
        end
          else
        begin
          // TODO: isolate all unit types
          case TSciterValueUnitTypeObject(pUnits) of
            UT_OBJECT_ARRAY, UT_OBJECT_OBJECT, UT_OBJECT_ERROR:
              begin
                Result := API.ValueIsolate(Value);
                Result := S2V(Value, OutValue);
                Exit;
              end;
          end;

          OutValue := GetNativeObjectJson(Value);
          Result := HV_OK;
        end;
      end;
    T_UNDEFINED:
      begin
        OutValue := Unassigned;
        Result := HV_OK;
      end;
    else
      begin
        raise ESciterNotImplementedException.CreateFmt('Conversion from Sciter type %d to Variant is not implemented.', [Integer(pType)]);
      end;
  end;
end;

{ Variant to SciterValue conversion }
function V2S(const Value: Variant; SciterValue: PSciterValue): UINT;
var
  sWStr: WideString;
  i64: Int64;
  c32: Cardinal;
  d: Double;
  date: TDateTime;
  st: SYSTEMTIME;
  ft: FILETIME;
  pDisp: IDispatch;
  cCur: Currency;
  vt: Word;
  i, j: Integer;
  oArrItem: Variant;
  sArrItem: TSciterValue;
  key, val, elem: TSciterValue;
  valfields: TArray<TRttiField>;
  rval, aval: TValue;
begin
  vt := VarType(Value);

  if (vt and varArray) = varArray then
  begin
    for i := VarArrayLowBound(Value, 1) to VarArrayHighBound(Value, 1) do
    begin
      oArrItem := VarArrayGet(Value, [i]);
      API.ValueInit(@sArrItem);
      V2S(oArrItem, @sArrItem);
      API.ValueNthElementValueSet(SciterValue, i, @sArrItem);
    end;
    Result := 0;
    Exit;
  end;

  case vt of
    varEmpty:
      Result := 0;
    varNull:
      Result := 0;
    varString,
    varUString,
    varOleStr:
      begin
        sWStr := Value;
        Result := API.ValueStringDataSet(SciterValue, PWideChar(sWStr), Length(sWStr), 0);
      end;
    varBoolean:
      begin
        if Value then
          Result := API.ValueIntDataSet(SciterValue, 1, T_BOOL, 0)
        else
          Result := API.ValueIntDataSet(SciterValue, 0, T_BOOL, 0);
      end;
    varByte,
    varSmallInt,
    varShortInt,
    varInteger,
    varWord:
      Result := API.ValueIntDataSet(SciterValue, Integer(Value), T_INT, 0);
    varUInt32:
      begin
        c32 := Value;
        Result := API.ValueIntDataSet(SciterValue, c32, T_INT, 0);
      end;
    varInt64:
      Result := API.ValueIntDataSet(SciterValue, Value, T_INT, 0);
    varSingle,
    varDouble:
      Result := API.ValueFloatDataSet(SciterValue, Double(Value), T_FLOAT, 0);
    varCurrency:
      begin
        cCur := Value;
        i64 := PInt64(@cCur)^;
        Result := API.ValueInt64DataSet(SciterValue, i64, T_CURRENCY, 0);
      end;
    varDate:
      begin
        date := TDateTime(Value);
        d := Double(date);
        VariantTimeToSystemTime(d, st);
        SystemTimeToFileTime(st, ft);
        i64 := Int64(ft);
        Result := API.ValueInt64DataSet(SciterValue, i64, T_DATE, 0);
      end;
    varDispatch:
      begin
        pDisp := IDispatch(Value);
        //pDisp._AddRef;
        Result := API.ValueBinaryDataSet(SciterValue, PByte(pDisp), 1, T_OBJECT, 0);
      end;
    else if vt = varRecordEx then
      begin
        valfields := TRTTIContext.Create.GetType(TRecordVarData(Value).VRecord.RecType).GetFields;
        for i := Low(valfields) to High(valfields) do
        begin
          API.ValueInit(@key);
          API.ValueInit(@val);
          API.ValueStringDataSet(@key, PWideChar(valfields[i].Name), Length(valfields[i].Name), UINT(UT_STRING_SYMBOL));

          rval := valfields[i].GetValue(TRecordVarData(Value).VRecord.RecObj);
          if rval.Kind = tkInteger then
            API.ValueIntDataSet(@val, rval.AsInteger, T_INT, 0)
          else if rval.Kind = tkEnumeration then
          begin
            if valfields[i].FieldType.Name = 'Boolean' then
            begin
              if rval.AsOrdinal = 1 then
                API.ValueIntDataSet(@val, 1, T_BOOL, 0)
              else
                API.ValueIntDataSet(@val, 0, T_BOOL, 0)
            end else
              API.ValueIntDataSet(@val, rval.AsOrdinal, T_INT, 0)
          end
          else if (rval.Kind = tkString) or (rval.Kind = tkWString) or (rval.Kind = tkUString) or (rval.Kind = tkLString) then
            API.ValueStringDataSet(@val, PWideChar(rval.AsString), Length(rval.AsString), 0)
          else if rval.Kind = tkFloat then
          begin
            date := TDateTime(rval.AsExtended);
            d := Double(date);
            VariantTimeToSystemTime(d, st);
            SystemTimeToFileTime(st, ft);
            i64 := Int64(ft);
            Result := API.ValueInt64DataSet(@val, i64, T_DATE, UINT(True));
          end else if (rval.Kind = tkArray) or (rval.Kind = tkDynArray) then
          begin
            for j := 0 to rval.GetArrayLength - 1 do
            begin
              API.ValueInit(@elem);
              aval := rval.GetArrayElement(j);
              if aval.Kind = tkInteger then
                API.ValueIntDataSet(@elem, aval.AsInteger, T_INT, 0)
              else if aval.Kind = tkEnumeration then
              begin
                if aval.AsBoolean then
                  API.ValueIntDataSet(@elem, 1, T_BOOL, 0)
                else
                  API.ValueIntDataSet(@elem, 0, T_BOOL, 0)
              end else if aval.Kind = tkUString then
              begin
                sWStr := aval.AsString;
                API.ValueStringDataSet(@elem, PWideChar(sWStr), Length(sWStr), 0);
              end else
                raise ESciterNotImplementedException.CreateFmt('Cannot convert array element of type %d to Sciter value.', [Integer(aval.Kind)]);
              API.ValueNthElementValueSet(@val, j, @elem);
              API.ValueClear(@elem);
            end;
          end else
            raise ESciterNotImplementedException.CreateFmt('Cannot convert record field of type %d to Sciter value.', [Integer(rval.Kind)]);

          Result := API.ValueSetValueToKey(SciterValue, @key, @val);
          API.ValueClear(@key);
          API.ValueClear(@val);
        end;
      end
    else
      raise ESciterNotImplementedException.CreateFmt('Cannot convert VARIANT of type %d to Sciter value.', [vt]);
  end;
end;

{ tiscript value to Variant conversion }
function T2V(const vm: HVM; Value: tiscript_value): Variant;
var
  sValue: TSciterValue;
begin
  API.ValueInit(@sValue);
  API.Sciter_T2S(vm, Value, sValue, False);
  S2V(@sValue, Result);
  API.ValueClear(@sValue);
end;

{ Variant to tiscript value conversion }
function V2T(const vm: HVM; const Value: Variant): tiscript_value;
var
  sValue: TSciterValue;
  tResult: tiscript_value;
begin
  API.ValueInit(@sValue);
  V2S(Value, @sValue);
  API.Sciter_S2T(vm, @sValue, tResult);
  Result := tResult;
  API.ValueClear(@sValue);
end;

{ ESciterNullPointerException }

constructor ESciterNullPointerException.Create;
begin
  inherited Create('The argument cannot be null.');
end;

{ ESciterCallException }

constructor ESciterCallException.Create(const MethodName: String);
begin
  inherited CreateFmt('Method "%s" call failed.', [MethodName]);
end;

initialization
  HSCITER := 0;
  RecordVariantType := TRecordVariantType.Create;
  varRecordEx := RecordVariantType.VarType;

finalization
  FreeAndNil(RecordVariantType);
  if HSCITER <> 0 then
    FreeLibrary(HSCITER);

end.
