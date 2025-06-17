unit schoolbotplugin;

{$mode objfpc}{$H+}

interface

uses
  brooktelegramaction, eventlog, opcoursesqlite3, tgtypes,
  SchoolEntities, tgsendertypes, fpjson, Classes, fgl, opstorage
  ;

type

  { TSchoolBotPlugin }

  TSchoolBotPlugin = class(TWebhookAction)
  private
    FAllCanCreateCourse: Boolean;
    FCoursesDB: TopCoursesDB;
    FFeedbackChat: Int64;
    FIsDialogSession: Boolean;
    FIsTeacherSession: Boolean;
    FLanguages: TStrings;
    procedure AcceptInvitation(aInvitationID: Integer);
    procedure BeforeCommand;
    procedure BotAfterParseUpdate({%H-}Sender: TObject);
    procedure BotCallbackInvitation({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackNew({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackDelete({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackEdit({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackInput({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackLaunch({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackList({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackReplace({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackSet({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackSettings({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCallbackSetLang({%H-}ASender: TObject; {%H-}ACallback: TCallbackQueryObj);
    procedure BotCommandList({%H-}ASender: TObject; const {%H-}ACommand: String;
      {%H-}AMessage: TTelegramMessageObj);
    procedure BotCommandEdit({%H-}ASender: TObject; const {%H-}ACommand: String;
      {%H-}AMessage: TTelegramMessageObj);
    procedure BotCommandLaunch({%H-}ASender: TObject; const {%H-}ACommand: String;
      {%H-}AMessage: TTelegramMessageObj);
    procedure BotCommandNewCourse({%H-}ASender: TObject; const {%H-}ACommand: String;
      {%H-}AMessage: TTelegramMessageObj);
    procedure BotCommandSet({%H-}ASender: TObject; const {%H-}ACommand: String;
      {%H-}AMessage: TTelegramMessageObj);
    procedure BotReceiveInlineQuery({%H-}ASender: TObject; AnInlineQuery: TTelegramInlineQueryObj);
    procedure BotReceiveMessage({%H-}ASender: TObject; AMessage: TTelegramMessageObj);
    procedure BotReceiveMessageText(const aMsg: String);
    procedure BotSendEntityContent(const aText, aMedia: String; aMediaType: TContentType;
      aParseMode: TParseMode; aReplyMarkup: TReplyMarkup);
    procedure BotSettings(const aDataMsg: String = '');
    function CaptionFromEntity(aEntityType: TEntityType): String;
    function CheckParents(aEntityType: TEntityType; aID: Int64; out aParentID: Int64): Boolean;
    function CheckChannelMember(aChat: Int64; aUser: Int64): Boolean;
    function CheckRights(aEntity: TEntityType; aID: Integer; out aFound: Boolean): Boolean;
    function CheckLicRights(aEntity: TEntityType; aID: Integer): Boolean;
    function CheckIsTested(aEntity: TEntityType): Boolean;
    procedure CommandNew(aEntity: TEntityType; aParentID: Integer);
    procedure CommandNew(const aData: String);
    function CreateQryResultLaunch(aEntityType: TEntityType; aID: Int64): TInlineQueryResult;
    function CreateInKbNotFound: TInlineKeyboard;
    function CreateInKbLaunchCourse: TInlineKeyboard;
    function CreateInKbLaunchLesson: TInlineKeyboard;
    function CreateInKbLaunchSlide(aSlideID: Integer): TInlineKeyboard;
    function CreateInKbInvitation(aInvitationID: Integer): TInlineKeyboard;
    function CreateInKbListCourses: TInlineKeyboard;
    function CreateInKbListLessons: TInlineKeyboard;
    function CreateInKbListSlides: TInlineKeyboard;
    function CreateInKbListStudentSpots(IsCourseOwner: Boolean; aEntityType: TEntityType): TInlineKeyboard;
    function CreateInKbListInvitations: TInlineKeyboard;
    function CreateInKbListUsers: TInlineKeyboard;
    function CreateInKbList(aEntity: TEntityType; aID: Int64 = 0; IsCourseOwner: Boolean = True): TInlineKeyboard;
    function CreateInKbSession4Teacher(aSpotID, aLessonID: Integer): TInlineKeyboard;
    function CreateInKbStngs: TInlineKeyboard;
    function CreateInKbStngsLang: TInlineKeyboard;
    function CreateInKbConfirmDelete(aEntity: TEntityType; aID: Integer): TInlineKeyboard;
    function CreateInKbEditLesson(aID: Integer): TInlineKeyboard;
    function CreateInKbEditCourse(aID: Integer): TInlineKeyboard;
    function CreateInKbEditCourseAccess(aID: Integer): TInlineKeyboard;
    function CreateInKbEditCourseStudents(aCourseID: Integer): TInlineKeyboard;
    function CreateInKbEditCourseTeacher(aCourseID: Integer): TInlineKeyboard;
    function CreateInKbEditCourseTeacherList(aCourseID: Integer): TInlineKeyboard;
    function CreateInKbEditTurn(aEntityType: TEntityType; aID: Int64; const aField: String): TInlineKeyboard;
    function CreateInKbEditReplace(aEntityType: TEntityType; aID: Int64): TInlineKeyboard;
    function CreateInKbEditInvitation(aInvitationID: Integer): TInlineKeyboard;
    function CreateInKbEditInvitationTeacher(aInvitationID: Integer): TInlineKeyboard;
    function CreateInKbEditSlide(aSlideID: Integer): TInlineKeyboard;
    function CreateInKbEditUser(aUserID: Int64): TInlineKeyboard;
    function CreateInKbOpenDialog(aSessionID: Integer): TInlineKeyboard;
    function CreateReplyKeyboardStart: TReplyMarkup;
    function CreateReplyKeyboardDialogSession: TKeyboardButtonArray;
    procedure DataFieldSet(aEntityType: TEntityType; aID: Int64; const aField: String;
      const aValue: String; aMessage: TTelegramMessageObj);
    procedure DataFieldSet(const aData: String; aMessage: TTelegramMessageObj);
    function GetCoursesDB: TopCoursesDB;
    function GetUserFromCurrentChatId: TUser;
    function InlnKybrd4StngsLang(aInlineKeyboard: TInlineKeyboard;
      aLangList: TStrings; const LCode, aSetLangCmd: String): Boolean;
    procedure HandleStart(const aParameter: String = '');
    procedure HandleHelp;
    function HandleLaunchCourse(aCourseID: Integer; out aText: String; out aParseMode: TParseMode;
      aReplyMarkup: TReplyMarkup; out aContentType: TContentType; out aMedia: String): Boolean;
    function HandleLaunchLesson(aLessonID: Integer; out aText: String; out aParseMode: TParseMode;
      aReplyMarkup: TReplyMarkup; out aContentType: TContentType; out aMedia: String): Boolean;
    function HandleLaunchSlide(aSlideID: Integer; out aText: String; out aParseMode: TParseMode;
      aReplyMarkup: TReplyMarkup; out aContentType: TContentType; out aMedia: String): Boolean;
    procedure HandleDelete(const aData: String);
    procedure HandleDelete(aEntityType: TEntityType; aID: Int64);
    function HandleSendInvitation(aInvitationID: Integer; out aText: String; out aParseMode: TParseMode;
      aReplyMarkup: TReplyMarkup; out aContentType: TContentType; out aMedia: String): Boolean;
    procedure OpenSession(aSessionID: Integer);
    procedure QueryResultsLaunch(const aData: String; const aQueryID: String);
    procedure QueryResultsFindNewBot(const aQueryID: String);
    procedure ReplyToCommandMessage(AMessage: TTelegramMessageObj);
    procedure SaveCurrentUser;
    procedure SaveNewCourse(aUserID: Int64; const aName: String = '');
    procedure SaveNewInvitation(aCourseID: Integer; const aValue: String);
    procedure SaveNewLesson(aCourseID: Integer; const aName: String = '');
    procedure SaveNewSlide(aLessonID: Integer; aMessage: TTelegramMessageObj);
    procedure SchoolEntitySetField(aEntityType: TEntityType; aID: Int64; const aField: String;
      const aValue: String; aMessage: TTelegramMessageObj);
    procedure SendDialogStart(const aData: String);
    procedure SendDialogStart(aEntityType: TEntityType; aID: Int64);
    procedure SendDialogExit(aSession: TSession);
    procedure SendDialogReturnToCourse(aSession: TSession);
    procedure SendDialogMessage(aMessage: TTelegramMessageObj);
    procedure SendEditAcceptTeacher(aLessonID: Integer);
    procedure SendEditContactButton(aID: Int64);
    procedure SendEditCourseInvitations(aCourseID: Integer);
    procedure SendEditCourseLicense(aCourseID: Integer);
    procedure SendEditCourseHistoryChat(aCourseID: Integer);
    procedure SendEditCourseStudents(aCourseID: Integer);
    procedure SendEditCourseTeacher(aCourseID: Integer);
    procedure SendEditDelete(aEntityType: TEntityType; aID: Int64);
    procedure SendEditInteractive(aEntityType: TEntityType; aID: Int64);
    procedure SendEditInvitationTeacher(aInvitationID: Integer);
    procedure SendEditMessage(const aData: String);
    procedure SendEditMessage(aEntityType: TEntityType; aID: Int64; const aField: String='');
    procedure SendEditReplace(aEntityType: TEntityType; aID: Int64);
    procedure SendEditTesting(aID: Integer);
    procedure SetEntityContent(aMessage: TTelegramMessageObj; aEntity: TCourseElement);
    procedure SendInput(const aData: String);
    procedure SendInput(aEntity: TEntityType; aID: Int64; const aField: String);
    procedure SendInvitation(aInvitationID: Integer);
    procedure SendLaunch(const aData: String);
    procedure SendLaunch(aEntityType: TEntityType; aID: Int64);
    procedure SendList(const aData: String = '');
    procedure SendList(aEntity: TEntityType; aID: Int64=0; aCSV: Boolean = False);
    procedure SendListStudentsCSVFromCourse;
    procedure SendNameInput(aEntity: TEntityType; aID: Int64 = 0);
    procedure SendReplace(const aData: String);
    procedure SendReplace(aEntityType: TEntityType; aID1, aID2: Int64);
    procedure SetLang(const aLangCode: String);
  protected
    property AllCanCreateCourse: Boolean read FAllCanCreateCourse write FAllCanCreateCourse;
    property CoursesDB: TopCoursesDB read GetCoursesDB;
    property FeedbackChat: Int64 read FFeedbackChat write FFeedbackChat;
    property Languages: TStrings read FLanguages write FLanguages;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Post; override;
    property IsDialogSession: Boolean read FIsDialogSession;
    property IsTeacherSession: Boolean read FIsTeacherSession;
  end;

function ContentFromMessage(aMessage: TTelegramMessageObj; out aText: String; out aMedia: String): TContentType;
function GetDataNew(aEntityType: TEntityType; aParentID: Int64): String;
function GetDataSet(aEntityType: TEntityType; aID: Int64; const aField: String; const aValue: String): String;
function GetDataEdit(aEntityObject: TSchoolElement; const aField: String = ''): String;
function GetDataEdit(aEntityType: TEntityType; aID: Int64=0; const aField: String = ''): String;
function GetDataInput(aEntityType: TEntityType; aID: Int64=0; const aField: String = ''): String;
function GetDataList(aEntityType: TEntityType; aID: Int64=0; const aParameter: String = ''): String;
function GetDataLaunch(aEntityType: TEntityType; aID: Integer): String;
function GetDataLaunch(aEntityObject: TCourseElement): String;
function GetDataReplace(aEntityType: TEntityType; aID1, aID2: Int64): String;
function GetDataDelete(aEntityType: TEntityType; aID: Integer): String;
function GetDataNewSession(aEntityType: TEntityType; aID: Int64): String;
function CaptionInputValue(const aField: String): String;
function CaptionFromChat(aChat: TTelegramChatObj): String;
function CaptionFromUser(AUser: TTelegramUserObj): String;

implementation

uses
  sysutils, strutils, tgutils, base64
  ;

const
  emj_TurnedOn='✅';
  emj_New='🆕';
  emj_ArrowUp='⬆️';
  emj_Projector='📽️';
  emj_CrossMark='❌';
  emj_Shuffle='🔀';
  emj_Share='🔗';
  emj_Teacher='👨‍🏫';
  emj_CheckBox='🗹';

  dt_settings='settings';

  dt_NewCourse='newcourse';
  dt_new='new';
  dt_list='list';
  dt_lang='lang';
  dt_SetLang='setlang';
  dt_edit='edit';
  dt_input='input';
  dt_set='set';
  dt_delete='delete';
  dt_name='name';
  dt_content='content';
  dt_text='text';
  dt_launch='launch';
  dt_replace='replace';
  dt_access='access';
  dt_accept='accept';
  dt_invitation='invitation';
  dt_interactive='interactive';
  dt_contact='contact';
  dt_showcontact='showcontact';
  dt_teacher='teacher';
  dt_student='student';
  dt_testing='testing';
  dt_lesson='lesson';
  dt_historychat='historychat';
  dt_csv='csv';

  //MaxMsgLength = 1024*3+255;   // Maximum message length to send
  //MsgPartLength = 3500;  // Length of one message part for the splitting

resourcestring
  s_Help='Help';
  s_Settings='Settings';
  s_CourseCreation='Creating courses';
  s_StartMenu='Start menu';
  s_IStudent='I am a student';
  s_ITeacher='I am a teacher';
  s_Student='Student';
  s_NewCourse='New course';
  s_MyCourses='My courses';
  s_Back='Back';
  s_ConfLang='Interface Language';    // Выбрать язык бота
  s_SettingsText='Here you can customize';   //Здесь Вы можете настроить словари под себя.'+LineEnding+LineEnding+
  s_SettingsLang='Interface Language:'; //Выберите язык бота:';
  s_StartText='Start text';
  s_HelpText='Help text';
  s_InputName='Please, input name';
  s_InputValue='Please, input new value';
  s_InputSlideText='Please, input text or/and insert media (image/video/audio or other file)';
  s_InputContact='Input course''s contact link (like https://t.me/tgschoolsadmin or http://homepage.com) for `Contact us` button';
  s_inputInvCapacity='Enter the number of people you want to invite';
  s_Name='Name';
  s_Access='Access';
  s_New='New';
  s_turnedOn='turned on';
  s_turnedOff='turned off';
  s_Interactive='Interactive';
  s_InteractiveButton='Interactive button';
  s_Demo='Demonstration';
  s_Delete='Delete';
  s_Replace='Replace';
  s_WhileNoLessons='This course does not yet have lessons created';
  s_UserNotHaveCourses='The user does not have courses yet';
  s_WhileNoSlides='This lesson does not yet have slides created';
  s_Share='Share';
  s_AcceptInvitation='Accept the invitation';
  s_InvitationText='Invitation to the course';
  s_InvitationNotValid='Invitation not valid or ended';
  s_StartDialog='You started the dialogue. To exit it, use any command (for example, /start) or write "'+mdCode+'Exit the dialog"'+mdCode;
  s_DialogExit='Exit from dialogue';
  s_ReturnToCourse='Return to the course';
  s_EndDialog='End the dialogue';
  s_OpenDialog='Open the dialogue';
  s_WntYStrtDlg='Want You to start dialogue?';
  s_ContactLink='Contact link';
  s_ContactButton='Contact us button';
  s_CommunicationViaBot='Contact with You via bot';
  s_CommunicationContact='Contact with via link';
  s_ShowContact='Contact button';
  s_Content='Content';
  s_CoverNDescr='Cover/description';
  s_CourseCount='Course count';
  s_LessonCount='Lesson count';
  s_SlideCount='Slide count';
  s_AlrdyInCrs='You are already in this course';
  s_CntTchrAndStdnt='You can''t be a teacher and a student at the same time';
  s_CourseName='Course name';
  s_Cancel='Cancel';
  s_SelectToSwap='Select the entity to swap places';
  s_ConfirmDelete='Are you sure you want to delete it?';
  s_InteractiveDescription='Interactivity button. '+
    'You can enable it if the teacher is required to receive answers from students at a given place'+
    ' or for feedback via a bot. The student does not see the contact of the teacher';
  s_ContactDescription='Contact button. You can enable if you want to give a link to Your website,'+
    ' telegram, etc. You can configure a contact link via the button ';
  s_State='State';
  s_NextLesson='Next lesson';
  s_ForTeacher='for teacher';
  s_SelectTeacher='Select teacher for this invitation';
  s_WithTesting='With testing';
  s_TestingDescription='Go to the next lesson only after the test';
  s_AcceptedTeacherInvitation='You accepted the invitation to become a teacher';
  s_AcceptedStudentInvitation='You became a student of the course';
  s_PassGrade='Pass grade/test';
  s_YouPassedNextLesson='You set a student to next lesson';
  s_StudentPassedCourse='The student passed the course';
  s_YouPassedTest='You passed a test for the lesson. You can proceed to the next lesson';
  s_YCntCrtCrs='You can''t create a course';
  s_SntMsgThtBtCldntRgnz='You sent a message that the bot couldn''t recognize. '+
    'Perhaps you wanted to send a message to the other person. '+
    'To do this you must click button %s or %s';
  s_DownloadCSV='Download as a CSV';

  lng_English='English';
  lng_Russian='Russian';
  lng_Spanish='Spanish';
  lng_Arabic='Arabic';
  lng_Belarusian='Belarusian';
  lng_Hebrew='Hebrew';
  lng_Italian='Italian';
  lng_Kazakh='Kazakh';
  lng_Portuguese='Portuguese';
  lng_Tajik='Tajik';
  lng_Ukrainian='Ukrainian';
  lng_French='French';
  lng_German='German';


  s_Storage='Storage';

function CaptionFromLangCode(const aLangCode: String): String;
var
  i: Integer;
begin
  i:=AnsiIndexStr(aLangCode, ['en', 'ru', 'es', 'ar', 'be', 'he', 'it', 'kk', 'pt', 'tg', 'uk', 'fr', 'de']);
  case i of
    0:  Result:=lng_English;
    1:  Result:=lng_Russian;
    2:  Result:=lng_Spanish;
    3:  Result:=lng_Arabic;
    4:  Result:=lng_Belarusian;
    5:  Result:=lng_Hebrew;
    6:  Result:=lng_Italian;
    7:  Result:=lng_Kazakh;
    8:  Result:=lng_Portuguese;
    9:  Result:=lng_Tajik;
    10: Result:=lng_Ukrainian;
    11: Result:=lng_French;
    12: Result:=lng_German;
  else
    Result:=EmptyStr;
  end;
end;

function GetDataFromLine(const ALine: String): String;
var
  i: SizeInt;
begin
  Result:=EmptyStr;
  i:=Pos(' ', ALine);
  if i>0 then
    Result:=Trim(RightStr(ALine, Length(ALine)-i));
end;

function ContentFromMessage(aMessage: TTelegramMessageObj; out aText: String;
  out aMedia: String): TContentType;
begin
  Result:=stUnknown;
  aText:=aMessage.Text;
  if aText<>EmptyStr then
    Exit(stText);
  aText:=aMessage.Caption;
  if Assigned(aMessage.Photo) then if (aMessage.Photo.Count>0) then
  begin
    aMedia:=aMessage.Photo.Last.FileID;
    Exit(stPhoto);
  end;
  if Assigned(aMessage.Video) then
  begin
    aMedia:=aMessage.Video.FileID;
    Exit(stVideo);
  end;
  if Assigned(aMessage.Voice) then
  begin
    aMedia:=aMessage.Voice.FileID;
    Exit(stVoice);
  end;
  if Assigned(aMessage.Audio) then
  begin
    aMedia:=aMessage.Audio.FileID;
    Exit(stAudio);
  end;
  if Assigned(aMessage.Document) then
  begin
    aMedia:=aMessage.Document.FileID;
    Exit(stDocument);
  end;
end;

function GetDataNew(aEntityType: TEntityType; aParentID: Int64): String;
begin
  Result:=dt_new+' '+EntityTypeToString(aEntityType);
  if aParentID<>0 then
    Result+=' '+aParentID.ToString;
end;

function GetDataSet(aEntityType: TEntityType; aID: Int64; const aField: String; const aValue: String
  ): String;
begin
  Result:=dt_set+' '+EntityTypeToString(aEntityType)+' '+aID.ToString;
  if aField<>EmptyStr then
    Result+=' '+aField;
  if aValue<>EmptyStr then
    Result+=' '+aValue;
end;

function GetDataEdit(aEntityObject: TSchoolElement; const aField: String
  ): String;
begin
  Result:=GetDataEdit(aEntityObject.EntityType, aEntityObject.ID64, aField);
end;

function GetDataEdit(aEntityType: TEntityType; aID: Int64;
  const aField: String): String;
begin
  Result:=dt_edit+' '+EntityTypeToString(aEntityType);
  if aID<>0 then
    Result+=' '+aID.ToString;
  if aField<>EmptyStr then
    Result+=' '+aField;
end;

function GetDataInput(aEntityType: TEntityType; aID: Int64;
  const aField: String): String;
begin
  Result:=dt_input+' '+EntityTypeToString(aEntityType);
  Result+=' '+aID.ToString;
  if aField<>EmptyStr then
    Result+=' '+aField;
end;

function GetDataList(aEntityType: TEntityType; aID: Int64;
  const aParameter: String): String;
begin
  Result:=dt_list+' '+EntityTypeToString(aEntityType);
  if aID<>0 then
    Result+=' '+aID.ToString;
  if aParameter<>EmptyStr then
    Result+=' '+aParameter;
end;

function GetDataLaunch(aEntityType: TEntityType; aID: Integer): String;
begin
  Result:=dt_launch+' '+EntityTypeToString(aEntityType);
  if aID<>0 then
    Result+=' '+aID.ToString;
end;

function GetDataLaunch(aEntityObject: TCourseElement): String;
begin
  Result:=GetDataLaunch(aEntityObject.EntityType, aEntityObject.id);
end;

function GetDataReplace(aEntityType: TEntityType; aID1, aID2: Int64): String;
begin
  Result:=dt_replace+' '+EntityTypeToString(aEntityType)+' '+aID1.ToString+' '+aID2.ToString;
end;

function GetDataDelete(aEntityType: TEntityType; aID: Integer): String;
begin
  Result:=dt_delete+' '+EntityTypeToString(aEntityType)+' '+aID.ToString;
end;

function GetDataNewSession(aEntityType: TEntityType; aID: Int64): String;
begin
  Result:=dt_new+' '+EntityTypeToString(seSession)+' '+EntityTypeToString(aEntityType)+' '+
    aID.ToString;
end;

function CaptionInputValue(const aField: String): String;
begin
  case AnsiIndexStr(aField, [dt_name, dt_content, dt_contact]) of
    0: Result:=s_InputName;
    1: Result:=s_InputSlideText;
    2: Result:=s_InputContact;
  else
    Result:=s_InputValue;
  end;
end;

function CaptionFromChat(aChat: TTelegramChatObj): String;
begin
  Result:=EmptyStr;
  with aChat do
  begin
    if First_name<>EmptyStr then
      Result+=First_name+' ';
    if Last_name<>EmptyStr then
      Result+=Last_name+' ';
    if Title<>EmptyStr then
      Result+=Title+' ';
    if Username<>EmptyStr then
      Result+='@'+Username;
  end;
  Result:=Trim(Result);
end;

function CaptionFromUser(AUser: TTelegramUserObj): String;
begin
  Result:=EmptyStr;
  with AUser do
  begin
    if First_name<>EmptyStr then
      Result+=First_name+' ';
    if Last_name<>EmptyStr then
      Result+=Last_name+' ';
    if Username<>EmptyStr then
      Result+='@'+Username;
  end;
  Result:=Trim(Result);
end;

{ TSchoolBotPlugin }

procedure TSchoolBotPlugin.AcceptInvitation(aInvitationID: Integer);
var
  aLeft: Integer;
  aReplyMarkup: TReplyMarkup;
  aMsg: String;
begin
  Bot.UpdateProcessed:=True;
  with CoursesDB.GetInvitationByID(aInvitationID) do
    aLeft:=Capacity-Applied;
  if aLeft<=0 then
  begin
    Bot.EditOrSendMessage(s_InvitationNotValid, pmMarkdown);
    Exit;
  end;
  aReplyMarkup:=CreateReplyKeyboardStart;
  try
    if CoursesDB.SpotInCourse(Bot.CurrentChatId, CoursesDB.Invitation.Course) then
      if ((CoursesDB.Invitation.UserStatus=usTeacher) and (CoursesDB.StudentSpot.UserStatus=usStudent)) or
        ((CoursesDB.Invitation.UserStatus=usStudent) and (CoursesDB.StudentSpot.UserStatus=usTeacher)) then
        Bot.sendMessage(s_CntTchrAndStdnt, pmMarkdown)
      else
        Bot.sendMessage(s_AlrdyInCrs, pmMarkdown)
    else begin
      CoursesDB.NewStudentSpot(Bot.CurrentChatId, CoursesDB.Invitation.Course, CoursesDB.Invitation.UserStatus,
        CoursesDB.Invitation.Teacher);
      Bot.Logger.Debug('Chat_ID: '+Bot.CurrentChatId.ToString);
      SaveCurrentUser;
      Bot.Logger.Debug('User: '+CoursesDB.User.Name);
      with CoursesDB.Invitation do
        Applied:=Applied+1;
      CoursesDB.SaveInvitation;
      case CoursesDB.Invitation.UserStatus of
        usStudent: aMsg:=s_AcceptedStudentInvitation;
        usTeacher: aMsg:=s_AcceptedTeacherInvitation;
      else
        aMsg:=s_AcceptInvitation;
      end;
      Bot.sendMessage(aMsg, pmMarkdown, True, aReplyMarkup);
    end;
  finally
    aReplyMarkup.Free;
  end;
  with CoursesDB do
    case Invitation.UserStatus of
      usStudent: SendLaunch(seSlide,
        GetSlidesList(GetLessonsList(GetCourseByID(Invitation.Course).id).First.id).First.id
        );
      usTeacher: SendLaunch(seCourse, Invitation.Course);
    else
      Logger.Error('Unknown user status while accept invitation');
    end;
end;

procedure TSchoolBotPlugin.BotAfterParseUpdate(Sender: TObject);
begin
  Bot.Language:=CoursesDB.GetUserByID(Bot.CurrentChatId).lang;
  FIsDialogSession:=False;
  FIsTeacherSession:=False;
  if CoursesDB.SessionExists(Bot.CurrentChatId) then
  begin
    if CoursesDB.Session.Student=Bot.CurrentChatId then
    begin
      FIsDialogSession:=True;
      Exit;
    end;
    if CoursesDB.Session.Teacher=Bot.CurrentChatId then
    begin
      FIsTeacherSession:=True;
      Exit;
    end;
    Bot.Logger.Error('Session #'+CoursesDB.Session.ID.ToString+' was not opened by user #'+
      Bot.CurrentChatId.ToString);
  end;
end;

procedure TSchoolBotPlugin.BotCallbackInvitation(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  SendInvitation(StrToIntDef(ExtractWord(1, ACallback.Data, [' ']), 0));
end;

procedure TSchoolBotPlugin.BotCallbackNew(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  CommandNew(GetDataFromLine(ACallback.Data))
end;

procedure TSchoolBotPlugin.BotCallbackDelete(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  HandleDelete(ACallback.Data);
end;

procedure TSchoolBotPlugin.BotCallbackEdit(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  SendEditMessage(ACallback.Data);
end;

procedure TSchoolBotPlugin.BotCallbackInput(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  SendInput(ACallback.Data);
end;

procedure TSchoolBotPlugin.BotCallbackLaunch(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  SendLaunch(ACallback.Data);
end;

procedure TSchoolBotPlugin.BotCallbackList(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  SendList(ACallback.Data);
end;

procedure TSchoolBotPlugin.BotCallbackReplace(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  SendReplace(ACallback.Data);
end;

procedure TSchoolBotPlugin.BotCallbackSet(ASender: TObject;
  ACallback: TCallbackQueryObj);
begin
  DataFieldSet(ACallback.Data, ACallback.Message);
end;

procedure TSchoolBotPlugin.BotCallbackSettings(ASender: TObject; ACallback: TCallbackQueryObj);
begin
  BotSettings(GetDataFromLine(ACallback.Data));
end;

procedure TSchoolBotPlugin.BotCallbackSetLang(ASender: TObject;
  ACallback: TCallbackQueryObj);
var
  S: String;
begin
  S:=ExtractDelimited(2, ACallback.Data, [' ']);
  SetLang(S);
  Bot.Language:=S;
  BotSettings(GetDataFromLine(dt_settings+' '+dt_lang));
  HandleStart;
end;

procedure TSchoolBotPlugin.BotCommandNewCourse(ASender: TObject;
  const ACommand: String; AMessage: TTelegramMessageObj);
begin
  BeforeCommand;
  SendNameInput(seCourse);
end;

procedure TSchoolBotPlugin.BotCommandSet(ASender: TObject;
  const ACommand: String; AMessage: TTelegramMessageObj);
begin
  BeforeCommand;
  DataFieldSet(AMessage.Text, AMessage);
end;

procedure TSchoolBotPlugin.BotCommandList(ASender: TObject;
  const ACommand: String; AMessage: TTelegramMessageObj);
begin
  BeforeCommand;
  SendList(AMessage.Text);
end;

procedure TSchoolBotPlugin.BotCommandEdit(ASender: TObject;
  const ACommand: String; AMessage: TTelegramMessageObj);
begin
  BeforeCommand;
  SendEditMessage(AMessage.Text);
end;

procedure TSchoolBotPlugin.BotCommandLaunch(ASender: TObject;
  const ACommand: String; AMessage: TTelegramMessageObj);
begin
  BeforeCommand;
  SendLaunch(AMessage.Text);
end;

procedure TSchoolBotPlugin.BotReceiveInlineQuery(ASender: TObject;
  AnInlineQuery: TTelegramInlineQueryObj);
begin
  QueryResultsLaunch(AnInlineQuery.Query, AnInlineQuery.ID);
end;

procedure TSchoolBotPlugin.BotReceiveMessage(ASender: TObject;
  AMessage: TTelegramMessageObj);
begin
  if FIsDialogSession then
    begin
      case AnsiIndexText(AMessage.Text, [s_DialogExit, s_ReturnToCourse]) of
        0: SendDialogReturnToCourse(CoursesDB.Session);
        1: SendDialogReturnToCourse(CoursesDB.Session);
      else
        SendDialogMessage(AMessage);
      end;
      Exit;
    end;
  if FIsTeacherSession then
  begin
    case AnsiIndexText(AMessage.Text, [s_DialogExit, s_ReturnToCourse]) of
      0: SendDialogExit(CoursesDB.Session);
      1: SendDialogExit(CoursesDB.Session);
    else
      SendDialogMessage(AMessage);
    end;
    Exit;
  end;
  if Assigned(AMessage.ReplyToMessage) then
    ReplyToCommandMessage(AMessage)
  else begin
    //if Assigned(AMessage.Document) then
    //  BotReceiveDocument(AMessage)
    //else
    //  BotReceiveMessageText(AMessage.Text);
  end;
end;

procedure TSchoolBotPlugin.BotReceiveMessageText(const aMsg: String);
begin
  case AnsiIndexText(aMsg, [s_Settings, s_Help, s_CourseCreation, s_IStudent, s_ITeacher,
    s_NewCourse, s_MyCourses, s_StartMenu]) of
    0: BotSettings;
    1: Bot.sendMessage(s_HelpText, pmMarkdown, True);
    2, 6: SendList;
    3: SendList(seStudent);
    4: SendList(seTeacher);
    5: SendNameInput(seCourse);
    7: HandleStart;
  else
    Bot.sendMessage(Format(s_SntMsgThtBtCldntRgnz, [s_TestOrAsk, s_OpenDialog]));
  end;
end;

procedure TSchoolBotPlugin.BotSettings(const aDataMsg: String);
var
  AReplyMarkup: TReplyMarkup;
  aMsg: String;
begin
  AReplyMarkup:=TReplyMarkup.Create;
  try
    if aDataMsg=EmptyStr then
    begin
      AReplyMarkup.InlineKeyBoard:=CreateInKbStngs;
      aMsg:=s_SettingsText;
    end
    else begin
      if aDataMsg=dt_lang then
      begin
        AReplyMarkup.InlineKeyBoard:=CreateInKbStngsLang;
        aMsg:=s_SettingsLang;
      end
      else
        aMsg:='Unknown menu item';
    end;
    Bot.EditOrSendMessage(aMsg, pmMarkdown, AReplyMarkup, True);
  finally
    AReplyMarkup.Free;
  end;
end;

function TSchoolBotPlugin.CaptionFromEntity(aEntityType: TEntityType): String;
begin
  Result:=EmptyStr;
  if aEntityType>=seCourse then
    Result+=LineEnding+s_Course+': “*'+MarkdownEscape(CoursesDB.Course.Name)+'*”';
  if aEntityType>=seLesson then
    Result+=LineEnding+s_Lesson+': “*'+MarkdownEscape(CoursesDB.Lesson.Name)+'*”';
  if aEntityType>=seSlide then
  begin
    CoursesDB.GetSlidesList(CoursesDB.Lesson.id);
    Result+=LineEnding+s_Slide+': *№'+
      (CoursesDB.GetSlideIndexByID(CoursesDB.Slide.id)+1).ToString+'*';
  end;
  Result:=Trim(Result);
end;

procedure TSchoolBotPlugin.BeforeCommand;
begin
  if FIsDialogSession or FIsTeacherSession then
    SendDialogExit(CoursesDB.Session);
  Bot.UpdateProcessed:=True;
end;

function TSchoolBotPlugin.CheckRights(aEntity: TEntityType; aID: Integer; out aFound: Boolean): Boolean;
var
  aParentID: Int64;
begin
  Result:=False;
  if CheckParents(aEntity, aID, aParentID) then
    Exit(True);
  aFound:=aParentID>0;
  if not Bot.CurrentIsSimpleUser then
    Result:=True;
end;

function TSchoolBotPlugin.CheckLicRights(aEntity: TEntityType; aID: Integer
  ): Boolean;
var
  aFound: Boolean;
begin
  Result:=False;
  if CheckRights(aEntity, aID, aFound) then
    Exit(True); // проверка является ли он владельцем сущности, если да, то проверен и выход
  if not aFound then Exit(False); // если не найден, то нет и выход
  if CoursesDB.Course.LicType<ltPrivate then
    Result:=True
  else
    if CoursesDB.SpotInCourse(Bot.CurrentChatId, CoursesDB.Course.id) then
      Result:=True;
end;

function TSchoolBotPlugin.CheckIsTested(aEntity: TEntityType): Boolean;
var
  i, aLessonID: Integer;
begin
  Result:=True;
  with CoursesDB do
    if (aEntity>seCourse) and Course.Testing and
      (GetSpotByUserNCourse(Bot.CurrentChatId, Course.id).UserStatus<>usTeacher) then
      if GetLessonsList(Course.id).Count>1 then
      begin
        aLessonID:=Lesson.id;
        i:=GetLessonIndexByID(aLessonID);
        if i>0 then
        begin
          Result:=aLessonID<=StudentSpot.Lesson
        end
        else
          if i<0 then
          begin
            Logger.Error('Lesson ID not found');
            Result:=False;
          end;
      end;
end;

procedure TSchoolBotPlugin.CommandNew(aEntity: TEntityType; aParentID: Integer);
begin
  SendNameInput(aEntity, aParentID);
end;

procedure TSchoolBotPlugin.CommandNew(const aData: String);
var
  aParentID: LongInt;
  aEntity: TEntityType;
begin
  aEntity:=EntityFromString(ExtractWord(1, aData, [' ']));
  case aEntity of
    seSession:    SendDialogStart(aData);
  else
    aParentID:=StrToIntDef(ExtractWord(2, aData, [' ']), 0);
    CommandNew(aEntity, aParentID);
  end;
end;

function TSchoolBotPlugin.CreateInKbLaunchCourse: TInlineKeyboard;
var
  i: Integer;
  aLesson: TLesson;
  aUrl: String;
begin
  Result:=TInlineKeyboard.Create;
  i:=0;
  for aLesson in CoursesDB.Lessons do
  begin
    Inc(i);
    Result.AddButton(s_Lesson+' '+i.ToString+'. '+aLesson.Name, GetDataLaunch(aLesson), 2);
  end;
  if CoursesDB.Course.ShowContact then
  begin
    aUrl:=CoursesDB.Course.Contact;
    if aUrl=EmptyStr then
      aUrl:='tg://user?id='+CoursesDB.Course.Owner.ToString;
    Result.Add.AddButtonUrl(s_ContactUs, aUrl);
  end;
end;

function TSchoolBotPlugin.CreateInKbLaunchLesson: TInlineKeyboard;
var
  aData: String;
  i, aCourseID: Integer;
  aSlide: TSlide;
begin
  Result:=TInlineKeyboard.Create;
  aCourseID:=CoursesDB.Lesson.Course;
  aData:=GetDataLaunch(seCourse, aCourseID);
  Result.Add.AddButton(emj_ArrowUp+' '+s_Course, aData);
  Result.Add;
  i:=0;
  for aSlide in CoursesDB.Slides do
  begin
    Inc(i);
    Result.AddButton(s_Slide+' '+i.ToString+'. '+aSlide.Name, GetDataLaunch(aSlide), 2);
  end;
end;

function TSchoolBotPlugin.CreateInKbLaunchSlide(aSlideID: Integer
  ): TInlineKeyboard;
var
  aData: String;
  i, aLessonID, aCourseID: Integer;
begin
  Result:=TInlineKeyboard.Create;
  aLessonID:=CoursesDB.Slide.Lesson;
  aData:=GetDataLaunch(seLesson, aLessonID);
  Result.Add.AddButton(emj_ArrowUp+' '+s_Lesson, aData);
  if CoursesDB.Slide.Interactive then
  begin
    aData:=GetDataNewSession(seSlide, aSlideID);
    Result.AddButton(emj_Teacher+' '+s_TestOrAsk, aData);
  end;
  Result.Add;
  CoursesDB.GetSlidesList(aLessonID);
  i:=CoursesDB.GetSlideIndexByID(aSlideID);
  Dec(i);
  if i>-1 then
    Result.AddButton('<<', GetDataLaunch(CoursesDB.Slides.Items[i]), 2);
  Inc(i, 2);
  if i<CoursesDB.Slides.Count then
    Result.AddButton('>>', GetDataLaunch(CoursesDB.Slides.Items[i]), 2)
  else begin
    aCourseID:=CoursesDB.GetLessonByID(aLessonID).Course;
    if aCourseID=0 then
      Exit;
    CoursesDB.GetLessonsList(aCourseID);
    i:=CoursesDB.GetLessonIndexByID(aLessonID);
    with CoursesDB do
      if (i<Lessons.Count-1) and (GetSlidesList(Lessons.Items[i+1].id).Count>0) then
        Result.AddButton(s_NextLesson, GetDataLaunch(seSlide, Slides.First.id));
  end;
end;

function TSchoolBotPlugin.CreateInKbInvitation(aInvitationID: Integer
  ): TInlineKeyboard;
var
  aData: String;
begin
  Result:=TInlineKeyboard.Create;
  aData:=dt_accept+' '+aInvitationID.ToString;
  Result.Add.AddButtonUrl(s_AcceptInvitation, Bot.DeepLinkingUrl(EncodeStringBase64(aData)));
end;

procedure TSchoolBotPlugin.SaveNewCourse(aUserID: Int64; const aName: String);
var
  aReplyMarkup: TReplyMarkup;
  aID: Integer;
begin
  if aUserID=0 then
    aUserID:=Bot.CurrentChatId;
  if not FAllCanCreateCourse and Bot.CurrentIsSimpleUser then
  begin
    Bot.sendMessage(aUserID, s_YCntCrtCrs);
    Exit;
  end;
  CoursesDB.Course.Owner:=aUserID;
  CoursesDB.Course.Name:=aName;
  aID:=CoursesDB.NewCourse;
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditCourse(aID);
    Bot.sendMessage(s_Course+': '+CoursesDB.Course.Name, pmMarkdown, True, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SaveNewInvitation(aCourseID: Integer;
  const aValue: String);
begin
  CoursesDB.NewInvitation(aCourseID, StrToIntDef(aValue, 0));
  SendEditCourseInvitations(aCourseID);
end;

procedure TSchoolBotPlugin.SaveNewLesson(aCourseID: Integer; const aName: String
  );
var
  aReplyMarkup: TReplyMarkup;
begin
  CoursesDB.Lesson.Course:=aCourseID;
  CoursesDB.Lesson.Name:=aName;
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditLesson(CoursesDB.NewLesson);
    Bot.sendMessage(s_Lesson+': '+CoursesDB.Lesson.Name, pmMarkdown, True, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SchoolEntitySetField(aEntityType: TEntityType;
  aID: Int64; const aField: String; const aValue: String;
  aMessage: TTelegramMessageObj);
begin
  DataFieldSet(aEntityType, aID, aField, aValue, AMessage);
end;

procedure TSchoolBotPlugin.SendDialogStart(const aData: String);
var
  aEntity: TEntityType;
  aID: Int64;
begin
  aEntity:=EntityFromString(ExtractWord(2, aData, [' ']));
  if aEntity=seUnknown then
    Exit;
  aID:=StrToInt64Def(ExtractWord(3, aData, [' ']), 0);
  if aID=0 then
    Exit;
  SendDialogStart(aEntity, aID);
end;

procedure TSchoolBotPlugin.SendDialogStart(aEntityType: TEntityType; aID: Int64);
var
  aReplyMarkup: TReplyMarkup;
  aTeacher: Int64;
begin
  if not CheckLicRights(aEntityType, aID) then
  begin
    Bot.EditOrSendMessage(s_NotFound);
    Exit;
  end;
  if not CheckIsTested(aEntityType) then
  begin
    Bot.EditOrSendMessage(s_NotPassed);
    Exit;
  end;
  aTeacher:=CoursesDB.StudentSpot.Teacher;
  if aTeacher=0 then
  begin
    aTeacher:=CoursesDB.Course.Teacher;
    if aTeacher=0 then
      aTeacher:=CoursesDB.Course.Owner;
  end;
  CoursesDB.NewSessionStudent(Bot.CurrentChatId, aEntityType, aID, aTeacher);
  Bot.Logger.Debug('Session #'+CoursesDB.Session.ID.ToString);
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.ReplyKeyboardMarkup:=CreateReplyKeyboardDialogSession;
    aReplyMarkup.ResizeKeyboard:=True;
    Bot.sendMessage(s_StartDialog, pmMarkdown, True, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendDialogExit(aSession: TSession);
var
  aEntityType: TEntityType;
  aID: Integer;
  aReplyMarkup: TReplyMarkup;
begin
  aEntityType:=aSession.GetSourceEntityType;
  aID:=aSession.EntityID;
  if FIsDialogSession then
    if not CheckLicRights(aEntityType, aID) then
    begin
      Bot.EditOrSendMessage(s_NotFound);
      Exit;
    end
  else
    if FIsTeacherSession then
      if not CheckLicRights(aEntityType, aID) then
      begin
        Bot.EditOrSendMessage(s_NotFound);
        Exit;
      end;
  if not CheckIsTested(aEntityType) then
  begin
    Bot.EditOrSendMessage(s_NotPassed);
    Exit;
  end;
  CoursesDB.ExitDialog(Bot.CurrentChatId);
  aReplyMarkup:=CreateReplyKeyboardStart;
  try
    Bot.sendMessage(s_EndDialog, pmMarkdown, True, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendDialogReturnToCourse(aSession: TSession);
begin
  SendDialogExit(aSession);
  SendLaunch(aSession.GetSourceEntityType, aSession.EntityID);
end;

procedure TSchoolBotPlugin.SendDialogMessage(aMessage: TTelegramMessageObj);
var
  aID, aSessionID: Integer;
  aEntityType: TEntityType;
  aTargetUser: Int64;
  aReplyMarkup: TReplyMarkup;
  aMsg: String;
  aFound, aOpened: Boolean;
begin
  aEntityType:=CoursesDB.Session.GetSourceEntityType;
  aID:=CoursesDB.Session.EntityID;
  if FIsDialogSession then
  begin
    if not CheckLicRights(aEntityType, aID) then
    begin
      Bot.EditOrSendMessage(s_NotFound);
      Exit;
    end;
  end
  else begin
    if not CheckRights(aEntityType, aID, aFound) then
    begin
      Bot.EditOrSendMessage(s_NotFound);
      Exit;
    end;
  end;
  if not CheckIsTested(aEntityType) then
  begin
    Bot.EditOrSendMessage(s_NotPassed);
    Exit;
  end;
  if FIsDialogSession then
  begin
    aTargetUser:=CoursesDB.StudentSpot.Teacher;
    if aTargetUser=0 then
      begin
        aTargetUser:=CoursesDB.Course.Teacher;
        if aTargetUser=0 then
          aTargetUser:=CoursesDB.Course.Owner;
      end;
  end
  else
    aTargetUser:=CoursesDB.Session.Student;
  aSessionID:=CoursesDB.Session.ID;
  aOpened:=CoursesDB.SessionOpened(aTargetUser, aSessionID);
  if not aOpened then
  begin
    aReplyMarkup:=nil;
    Bot.Logger.Debug('CP1 '+'Course #'+CoursesDB.Course.id.ToString+'; Testing: '+
      CoursesDB.Course.Testing.ToString(True)+'; Entity type: '+EntityTypeToString(aEntityType));

    try
      if FIsDialogSession then
      begin
        if (CoursesDB.Course.Testing) and (aEntityType in [seLesson, seSlide]) then
        begin
          aReplyMarkup:=TReplyMarkup.Create;
          with CoursesDB do
            aReplyMarkup.InlineKeyBoard:=CreateInKbSession4Teacher(StudentSpot.id, Lesson.id);
          aMsg:=CaptionFromEntity(aEntityType)+LineEnding+s_Student+': ['+CaptionFromChat(aMessage.Chat)
            +'](tg://user?id='+aMessage.Chat.ID.ToString+')'+' '+s_WroteMsg;
        end
      end
      else
        aMsg:=CaptionFromEntity(aEntityType)+s_DYWntEntrDlg;
      Bot.sendMessage(aTargetUser, aMsg, pmMarkdown, False, aReplyMarkup);
    finally
      FreeAndNil(aReplyMarkup);
    end;
  end;
  Bot.forwardMessage(aTargetUser, Bot.CurrentChatId, False, aMessage.MessageId);
  if CoursesDB.Course.HistoryChat<>EmptyStr then
    Bot.forwardMessage(CoursesDB.Course.HistoryChat, Bot.CurrentChatId, True, aMessage.MessageId);
  if not aOpened then
  begin
    aReplyMarkup:=TReplyMarkup.Create;
    try
      aReplyMarkup.InlineKeyBoard:=CreateInKbOpenDialog(aSessionID);
      Bot.sendMessage(aTargetUser, s_WntYStrtDlg, pmMarkdown, False, aReplyMarkup);
    finally
      aReplyMarkup.Free
    end;
  end;
end;

procedure TSchoolBotPlugin.SendEditAcceptTeacher(aLessonID: Integer);
var
  IsLastLesson: Boolean;
  aMsg: String;
begin
  with CoursesDB do
  begin
    StudentSpot.Lesson:=aLessonID;
    SpotNextSlide(StudentSpot, IsLastLesson);
    SaveCourseEntity(seStudentSpot);
  end;
  aMsg:=s_YouPassedNextLesson;
  if IsLastLesson then
    aMsg+=LineEnding+s_StudentPassedCourse;
  Bot.EditOrSendMessage(aMsg, pmMarkdown);
  Bot.sendMessage(CoursesDB.StudentSpot.User, s_YouPassedTest, pmMarkdown);
end;

procedure TSchoolBotPlugin.SendEditContactButton(aID: Int64);
var
  aReplyMarkup: TReplyMarkup;
  aTurnedOn: Boolean;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aTurnedOn:=CoursesDB.GetCourseByID(aID).ShowContact;
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditTurn(seCourse, aID, dt_showcontact);
    Bot.EditOrSendMessage(s_State+': *'+BoolToStr(aTurnedOn, s_turnedOn, s_turnedOff)+'*'+LineEnding+
      s_ContactDescription+' '+mdCode+s_ContactLink+mdCode, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditCourseInvitations(aCourseID: Integer);
var
  aCount: Integer;
  aReplyMarkup: TReplyMarkup;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aCount:=CoursesDB.FindEntitiesByParentID(seInvitation, aCourseID, True);
    aReplyMarkup.InlineKeyBoard:=CreateInKbList(seInvitation, aCourseID);
    Bot.EditOrSendMessage(CaptionFromSchEntity(seInvitation, True)+' ('+aCount.ToString+')', pmMarkdown,
      aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditCourseLicense(aCourseID: Integer);
var
  aMsg: String;
  aReplyMarkup: TReplyMarkup;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditCourseAccess(aCourseID);
    aMsg:=s_Course+' “'+MarkdownEscape(CoursesDB.Course.Name)+'”'+LineEnding+
      mdCode+'ID: '+aCourseID.ToString+mdCode+LineEnding+s_Access+': '+LicTypeToCaption(CoursesDB.Course.LicType);
    Bot.EditOrSendMessage(aMsg, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditCourseHistoryChat(aCourseID: Integer);
var
  aMsg: String;
  aReplyMarkup: TReplyMarkup;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditCourseAccess(aCourseID);
    aMsg:=s_Course+' “'+MarkdownEscape(CoursesDB.Course.Name)+'”'+LineEnding+
      mdCode+'ID: '+aCourseID.ToString+mdCode+LineEnding+s_Access+': '+LicTypeToCaption(CoursesDB.Course.LicType);
    Bot.EditOrSendMessage(aMsg, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditCourseStudents(aCourseID: Integer);
var
  aReplyMarkup: TReplyMarkup;
  aCount: Integer;
  aFound: Boolean;
  aParentEntity: TEntityType;
  aMsg: String;
begin
  if not CheckRights(seCourse, aCourseID, aFound) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aCount:=CoursesDB.FindEntitiesByParentID(seStudent, aCourseID, True);
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditCourseStudents(aCourseID);
    aMsg:='*'+s_Students+'*'+' ('+aCount.ToString+')';
    aMsg+=LineEnding+mdCode;
    aMsg+=s_Course+': '+CoursesDB.Course.Name;
    if aParentEntity>seCourse then
      aMsg+=' | '+s_Lesson+': '+CoursesDB.Lesson.Name;
    aMsg+=mdCode;
    Bot.EditOrSendMessage(aMsg, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditCourseTeacher(aCourseID: Integer);
var
  aReplyMarkup: TReplyMarkup;
  aCount: Integer;
  aFound: Boolean;
  aMsg: String;
begin
  if not CheckRights(seCourse, aCourseID, aFound) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aCount:=CoursesDB.FindEntitiesByParentID(seTeacher, aCourseID, True);
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditCourseTeacher(aCourseID);
    aMsg:='*'+CaptionFromSchEntity(seTeacher, True)+'*'+' ('+aCount.ToString+')';
    aMsg+=LineEnding+mdCode+s_Course+': '+CoursesDB.Course.Name+mdCode;
    Bot.EditOrSendMessage(aMsg, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditDelete(aEntityType: TEntityType; aID: Int64);
var
  aReplyMarkup: TReplyMarkup;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.InlineKeyBoard:=CreateInKbConfirmDelete(aEntityType, aID);
    Bot.EditOrSendMessage('*'+s_ConfirmDelete+'*', pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditInteractive(aEntityType: TEntityType;
  aID: Int64);
var
  aReplyMarkup: TReplyMarkup;
  aTurnedOn: Boolean;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    CoursesDB.GetEntityByID(aEntityType, aID);
    aTurnedOn:=CoursesDB.CourseEntity[aEntityType].Interactive;
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditTurn(aEntityType, aID, dt_interactive);
    Bot.EditOrSendMessage(emj_Teacher+' '+s_State+': *'+BoolToStr(aTurnedOn, s_turnedOn, s_turnedOff)
      +'*'+LineEnding+s_InteractiveDescription, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditInvitationTeacher(aInvitationID: Integer);
var
  aReplyMarkup: TReplyMarkup;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    CoursesDB.GetInvitationByID(aInvitationID);
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditInvitationTeacher(aInvitationID);
    Bot.EditOrSendMessage(s_SelectTeacher, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

function TSchoolBotPlugin.CreateQryResultLaunch(aEntityType: TEntityType; aID: Int64): TInlineQueryResult;
var
  aMsg, aMedia, aCaption: String;
  aContentType: TContentType;
  aParseMode: TParseMode;

  procedure QueryResultArticle;
  begin
    Result.IQRType:=qrtArticle;
    Result.InputMessageContent:=TInputMessageContent.Create(aMsg, aParseMode);
  end;
  procedure QueryResultAudio;
  begin
    Result.IQRType:=qrtAudio;
    Result.Caption:=aMsg;
    Result.AudioFileID:=aMedia;
    Result.ParseMode:=aParseMode;
  end;
  procedure QueryResultPhoto;
  begin
    Result.IQRType:=qrtPhoto;
    Result.Caption:=aMsg;
    Result.PhotoFileID:=aMedia;
    Result.ParseMode:=aParseMode;
  end;
  procedure QueryResultVideo;
  begin
    Result.IQRType:=qrtVideo;
    Result.Caption:=aMsg;
    Result.VideoFileID:=aMedia;
    Result.ParseMode:=aParseMode;
  end;
  procedure QueryResultVoice;
  begin
    Result.IQRType:=qrtVoice;
    Result.Caption:=aMsg;
    Result.VoiceFileID:=aMedia;
    Result.ParseMode:=aParseMode;
  end;
  procedure QueryResultDocument;
  begin
    Result.IQRType:=qrtDocument;
    Result.Caption:=aMsg;
    Result.DocumentFileID:=aMedia;
    Result.ParseMode:=aParseMode;
  end;

begin
  Result:=TInlineQueryResult.Create;
  aContentType:=stText;
  Result.ReplyMarkup:=TReplyMarkup.Create;
  if (aID=0) or (aEntityType=seUnknown) then
  begin
    Result.Title:='Enter course/lesson/slide/invitation and its ID to launch';
    aMsg:='Enter `course` (or `lesson`/`slide`) and its ID to prepare for launch this. '+
      '. For example:'+LineEnding+mdCode+'course 3'+mdCode;
    aParseMode:=pmMarkdown;
  end
  else begin
    case aEntityType of
      seCourse:     HandleLaunchCourse(aID, aMsg, aParseMode, Result.ReplyMarkup, aContentType, aMedia);
      seLesson:     HandleLaunchLesson(aID, aMsg, aParseMode, Result.ReplyMarkup, aContentType, aMedia);
      seSlide:      HandleLaunchSlide(aID, aMsg, aParseMode, Result.ReplyMarkup, aContentType, aMedia);
      seInvitation: HandleSendInvitation(aID, aMsg, aParseMode, Result.ReplyMarkup, aContentType, aMedia);
    else
      Bot.Logger.Error('Unexpected entity type while HandleLaunch');
    end;
    aCaption:=CaptionFromSchEntity(aEntityType);
    case aEntityType of
      seCourse..seSlide: Result.Title:=aCaption+': '+CoursesDB.SchoolEntity[aEntityType].Name;
      seInvitation:      Result.Title:=aCaption+'. '+s_Course+' '+CoursesDB.GetCourseByID(CoursesDB.Invitation.Course).Name;
    else
      Bot.Logger.Error('Unexpected entity type while aCaption in CreateQueryResultLaunch');
    end;
    if (aEntityType<>seInvitation) and Assigned(Result.ReplyMarkup.InlineKeyBoard) then
      Result.ReplyMarkup.InlineKeyBoard.Add.AddButtonInline(emj_Share+' '+s_Share,
        EntityTypeToString(aEntityType)+' '+aID.ToString);
  end;
  Result.ID:='launch_'+EntityTypeToString(aEntityType)+'_'+aID.ToString;
  case aContentType of
    stText:  QueryResultArticle;
    stPhoto: QueryResultPhoto;
    stAudio: QueryResultAudio;
    stVideo: QueryResultVideo;
    stVoice: QueryResultVoice;
    stDocument: QueryResultDocument;
  else
    Bot.Logger.Error('Unexpected content type while QueryResult');
  end;
end;

function TSchoolBotPlugin.CreateInKbNotFound: TInlineKeyboard;
begin
  Result:=TInlineKeyboard.Create;
end;

procedure TSchoolBotPlugin.SaveNewSlide(aLessonID: Integer;
  aMessage: TTelegramMessageObj);
var
  aReplyMarkup: TReplyMarkup;
  aID: Integer;
  aMedia, aText: String;

begin
  CoursesDB.Slide.MediaType:=ContentFromMessage(aMessage, aText, aMedia);
  CoursesDB.Slide.Lesson:= aLessonID;
  CoursesDB.Slide.Text:=   aText;
  CoursesDB.Slide.Media:=  aMedia;
  aID:=CoursesDB.NewSlide;
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditSlide(aID);
    BotSendEntityContent(aText, aMedia, CoursesDB.Slide.MediaType, pmDefault, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendInvitation(aInvitationID: Integer);
var
  aReplyMarkup: TReplyMarkup;
  aParseMode: TParseMode;
  aText, aMedia: String;
  aContentType: TContentType;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    HandleSendInvitation(aInvitationID, aText, aParseMode, aReplyMarkup, aContentType, aMedia);
    BotSendEntityContent(aText, aMedia, aContentType, aParseMode, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendNameInput(aEntity: TEntityType; aID: Int64);
var
  aReplyMarkup: TReplyMarkup;
  s: String;
  aFound: Boolean;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  aReplyMarkup.ForceReply:=True;
  if (aID=0) and (aEntity=seCourse) then
    aID:=Bot.CurrentChatId;
  if aEntity=seUser then
  begin
    Bot.Logger.Error('Can''t create new user. Unavailable operation!');
    Exit();
  end;
  if not CheckRights(Pred(aEntity), aID, aFound) then
  begin
    Bot.EditOrSendMessage(s_NotFound);
    Exit;
  end;
  try
    s:='/'+GetDataNew(aEntity, aID)+LineEnding;
    case aEntity of
      seCourse..seLesson: s+=s_InputName;
      seSlide: s+=s_InputSlideText;
      seInvitation: s+=s_inputInvCapacity;
    else
      Bot.Logger.Error('Unexpected entity type while SendNameInput');
    end;
    if Assigned(Bot.CurrentMessage) then
      Bot.deleteMessage(Bot.CurrentMessage.MessageId);
    Bot.sendMessage(s, pmMarkdown, True, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendReplace(const aData: String);
var
  aEntityType: TEntityType;
  aID1, aID2: Int64;
  s: String;
begin
  s:=ExtractWord(2, aData, [' ']);
  aEntityType:=EntityFromString(s);
  if aEntityType=seUnknown then
    Exit;
  aID1:=StrToInt64Def(ExtractWord(3, aData, [' ']), 0);
  if aID1=0 then
    Exit;
  aID2:=StrToInt64Def(ExtractWord(4, aData, [' ']), 0);
  if aID2=0 then
    Exit;
  SendReplace(aEntityType, aID1, aID2);
end;

procedure TSchoolBotPlugin.SendReplace(aEntityType: TEntityType; aID1,
  aID2: Int64);
begin
  CoursesDB.ReplaceEntity(aEntityType, aID1, aID2);
  SendEditMessage(aEntityType, aID1);
end;

function TSchoolBotPlugin.CreateInKbListLessons: TInlineKeyboard;
var
  aLesson: TLesson;
begin
  Result:=TInlineKeyboard.Create;
  for aLesson in CoursesDB.Lessons do
    Result.AddButton(aLesson.Name, GetDataEdit(aLesson), 2);
end;

function TSchoolBotPlugin.CreateInKbListSlides: TInlineKeyboard;
var
  aSlide: TSlide;
  i: Integer;
begin
  Result:=TInlineKeyboard.Create;
  i:=0;
  for aSlide in CoursesDB.Slides do
  begin
    Inc(i);
    Result.AddButton(i.ToString+'. '+aSlide.Name, GetDataEdit(aSlide), 2);
  end;
end;

{ EntityType - Spot, Student or Teacher }
function TSchoolBotPlugin.CreateInKbListStudentSpots(IsCourseOwner: Boolean;
  aEntityType: TEntityType): TInlineKeyboard;
var
  aStudentSpot: TStudentSpot;
  aCourse: TCourse;
  aUser: TUser;
begin
  Result:=TInlineKeyboard.Create;
  for aStudentSpot in CoursesDB.StudentSpots do
  begin
    if IsCourseOwner then
    begin
      aUser:=CoursesDB.GetUserByID(aStudentSpot.User);
      Result.Add.AddButton(aUser.Name, GetDataLaunch(seUser, aUser.id));
    end
    else begin
      aCourse:=CoursesDB.GetCourseByID(aStudentSpot.Course);
      Result.Add.AddButton(aCourse.Name, GetDataLaunch(seCourse, aCourse.id));
    end;
    Result.AddButton(emj_CrossMark+' '+s_Delete, GetDataDelete(aEntityType, aStudentSpot.ID));
  end;
end;

function TSchoolBotPlugin.CreateInKbListInvitations: TInlineKeyboard;
var
  aInvitation: TInvitation;
  aCaption: String;
begin
  Result:=TInlineKeyboard.Create;
  for aInvitation in CoursesDB.Invitations do
  begin
    aCaption:=Format(s_AppliedFromAll, [aInvitation.Applied, aInvitation.Capacity]);
    Result.AddButton(aCaption, GetDataEdit(aInvitation), 1);
  end;
end;

function TSchoolBotPlugin.CreateInKbListCourses: TInlineKeyboard;
var
  aCourse: TCourse;
begin
  Result:=TInlineKeyboard.Create;
  for aCourse in CoursesDB.Courses do
    Result.AddButton(aCourse.Name, GetDataEdit(aCourse), 2);
end;

function TSchoolBotPlugin.CreateInKbListUsers: TInlineKeyboard;
var
  aUser: TUser;
begin
  Result:=TInlineKeyboard.Create;
  for aUser in CoursesDB.Users do
    Result.AddButton(aUser.Name, GetDataEdit(aUser.EntityType, aUser.id), 2);
end;

function TSchoolBotPlugin.CreateInKbList(aEntity: TEntityType; aID: Int64;
  IsCourseOwner: Boolean): TInlineKeyboard;
var
  aData: String;
  aUserStatus: TUserStatus;
begin
  case aEntity of
    seUser:   Result:=CreateInKbListUsers;
    seCourse: Result:=CreateInKbListCourses;
    seLesson: Result:=CreateInKbListLessons;
    seSlide:  Result:=CreateInKbListSlides;
    seInvitation: Result:=CreateInKbListInvitations;
    seStudentSpot..seTeacher: Result:=CreateInKbListStudentSpots(IsCourseOwner, aEntity);
  else
    Bot.Logger.Error('Unknown entity for inline keyboard');
    Result:=TInlineKeyboard.Create;
  end;
  if aEntity>seUser then
  begin
    if aEntity in [seStudentSpot..seTeacher] then
    begin
      case aEntity of
        seStudentSpot: aUserStatus:=usStudent;
        seStudent:     aUserStatus:=usStudent;
        seTeacher:    aUserStatus:=usTeacher;
      else
        aUserStatus:=usNone;
      end;
      if IsCourseOwner then
        Result.Add.AddButtonInline(emj_New+' '+s_New+' ('+CaptionFromSchEntity(aEntity)+')',
          dt_invitation+' '+aID.ToString+' 1 '+UserStatusToString(aUserStatus))
    end
    else begin
      if AllCanCreateCourse or not Bot.CurrentIsSimpleUser then
        Result.Add.AddButton(emj_New+' '+s_New+' ('+CaptionFromSchEntity(aEntity)+')', GetDataNew(aEntity, aID));
    end;
    if (aEntity in [seInvitation, seStudentSpot..seTeacher]) and IsCourseOwner then
    begin
      aData:=GetDataEdit(seCourse, aID);
      Result.Add.AddButton(emj_ArrowUp+' '+CaptionFromSchEntity(seCourse), aData);
      Exit;
    end;
    if not IsCourseOwner then
      Exit;
    if (aEntity>seCourse) or (Bot.CurrentChatId<>aID) then
    begin
      aData:=GetDataEdit(Pred(aEntity), aID);
      Result.Add.AddButton(emj_ArrowUp+' '+CaptionFromSchEntity(Pred(aEntity)), aData);
    end
    else begin
      aData:=dt_settings;
      Result.Add.AddButton(emj_ArrowUp+' '+s_Settings, aData);
    end;
  end;
end;

function TSchoolBotPlugin.CreateInKbSession4Teacher(aSpotID, aLessonID: Integer
  ): TInlineKeyboard;
begin
  Result:=TInlineKeyboard.Create;
  Result.Add.AddButton(s_PassGrade, GetDataSet(seStudentSpot, aSpotID, dt_lesson, aLessonID.ToString));
end;

function TSchoolBotPlugin.CreateInKbStngs: TInlineKeyboard;
begin
  Result:=TInlineKeyboard.Create;
  Result.AddButton(s_TeachCourses, GetDataList(seCourse), 2);
  Result.AddButton(s_TakeCourses, GetDataList(seStudent), 2);
  Result.AddButton(s_ConfLang, dt_settings+' '+dt_lang, 2);
  Result.AddButton(s_Storage, dt_storage+' '+dt_list, 2);
end;

function TSchoolBotPlugin.CreateInKbStngsLang: TInlineKeyboard;
begin
  Result:=TInlineKeyboard.Create;
  CoursesDB.GetUserByID(Bot.CurrentChatId);
  InlnKybrd4StngsLang(Result, FLanguages, CoursesDB.User.Lang, dt_SetLang);
  Result.Add.AddButton(s_Back+' '+emj_ArrowUp, dt_settings);
end;

function TSchoolBotPlugin.CreateInKbConfirmDelete(aEntity: TEntityType;
  aID: Integer): TInlineKeyboard;
begin
  Result:=TInlineKeyboard.Create;
  Result.AddButton(emj_CrossMark+' '+s_Delete, GetDataDelete(aEntity, aID), 2);
  Result.AddButton(s_Cancel+' '+emj_ArrowUp, GetDataEdit(aEntity, aID), 2);
end;

function TSchoolBotPlugin.CreateInKbEditLesson(aID: Integer
  ): TInlineKeyboard;
var
  aData, aCaption: String;
  ParentID: Int64;
  aTurned: Boolean;
begin
  Result:=TInlineKeyboard.Create;
  aData:=GetDataInput(seLesson, aID, dt_name);
  Result.AddButton(s_Name, aData, 3);
  aData:=GetDataInput(seLesson, aID, dt_content);
  Result.AddButton(s_CoverNDescr, aData, 3);
  aData:=GetDataList(seSlide, aID);
  Result.AddButton(s_Slides, aData, 3);
  aTurned:=CoursesDB.GetLessonByID(aID).Interactive;
  aCaption:=s_Interactive+' ('+BoolToStr(aTurned, s_turnedOn, s_turnedOff)+')';
  Result.AddButton(aCaption, GetDataEdit(seLesson, aID, dt_interactive), 3);
  ParentID:=CoursesDB.GetLessonByID(aID).Course;
  aData:=GetDataList(seLesson, ParentID);
  Result.Add.AddButton(emj_ArrowUp+' '+s_Lessons, aData);
  Result.AddButton(emj_projector+' '+s_Demo, GetDataLaunch(seLesson, aID), 3);
  Result.AddButton(emj_Shuffle+' '+s_Replace, GetDataEdit(seLesson, aID, dt_replace), 3);
  Result.AddButton(emj_CrossMark+' '+s_Delete, GetDataEdit(seLesson, aID, dt_delete), 3);
end;

function TSchoolBotPlugin.CreateInKbEditCourse(aID: Integer
  ): TInlineKeyboard;
var
  aData, aCaption: String;
  ParentID: Int64;
  aTurned: Boolean;
begin
  Result:=TInlineKeyboard.Create;
  aData:=GetDataInput(seCourse, aID, dt_name);
  Result.AddButton(s_CourseName, aData, 3);
  aData:=GetDataInput(seCourse, aID, dt_content);
  Result.AddButton(s_CoverNDescr, aData, 3);
  aData:=GetDataEdit(seCourse, aID, dt_access);
  Result.AddButton(s_Access, aData, 3);
  aData:=GetDataEdit(seCourse, aID, dt_invitation);
  Result.AddButton(s_Invitations, aData, 3);
  aData:=GetDataEdit(seCourse, aID, dt_student);
  Result.AddButton(s_Students, aData, 3);
  aData:=GetDataEdit(seCourse, aID, dt_teacher);
  Result.AddButton(s_Teachers, aData, 3);
  aData:=GetDataInput(seCourse, aID, dt_historychat);
  Result.AddButton(s_HistoryChat, aData, 3);
  aData:=GetDataList(seLesson, aID);
  Result.AddButton(CaptionFromSchEntity(seLesson, True), aData, 3);
  aData:=GetDataNew(seLesson, aID);
  Result.AddButton(emj_New+' '+s_New+' ('+CaptionFromSchEntity(seLesson)+')', aData, 3);
  Result.Add;
  aTurned:=CoursesDB.GetCourseByID(aID).Interactive;
  aCaption:=s_Interactive+' ('+BoolToStr(aTurned, s_turnedOn, s_turnedOff)+')';
  Result.AddButton(aCaption, GetDataEdit(seCourse, aID, dt_interactive), 3);
  aData:=GetDataInput(seCourse, aID, dt_contact);
  Result.AddButton(s_ContactLink, aData, 3);
  aData:=GetDataEdit(seCourse, aID, dt_showcontact);
  Result.AddButton(s_ShowContact, aData, 3);
  Result.AddButton(s_WithTesting, GetDataEdit(seCourse, aID, dt_testing), 3);
  ParentID:=CoursesDB.GetCourseByID(aID).Owner;
  aData:=GetDataList(seCourse, ParentID);
  Result.Add.AddButton(emj_ArrowUp+' '+s_Courses, aData);
  Result.AddButton(emj_projector+' '+s_Demo, GetDataLaunch(seCourse, aID), 3);
  Result.AddButton(emj_CrossMark+' '+s_Delete, GetDataEdit(seCourse, aID, dt_delete), 3);
end;

function TSchoolBotPlugin.CreateInKbEditCourseAccess(aID: Integer
  ): TInlineKeyboard;
var
  aData: String;
  lic: TLicType;
begin
  Result:=TInlineKeyboard.Create;
  for lic:=Succ(Low(TLicType)) to High(TLicType) do
  begin
    aData:=GetDataSet(seCourse, aID, dt_access, Ord(lic).ToString);
    Result.AddButton(LicTypeToCaption(lic), aData, 2);
  end;
  aData:=GetDataEdit(seCourse, aID);
  Result.Add.AddButton(emj_ArrowUp+' '+s_Course, aData);
end;

function TSchoolBotPlugin.CreateInKbEditCourseStudents(aCourseID: Integer
  ): TInlineKeyboard;
var
  aData: String;
begin
  Result:=CreateInKbListStudentSpots(True, seStudent);
  Result.AddButton(s_DownloadCSV, GetDataList(seStudent, aCourseID, dt_csv), 2);
  Result.Add.AddButtonInline(emj_New+' '+s_New+' ('+s_Student+')',
    dt_invitation+' '+aCourseID.ToString+' 1 '+UserStatusToString(usStudent));
  aData:=GetDataEdit(seCourse, aCourseID);
  Result.Add.AddButton(emj_ArrowUp+' '+CaptionFromSchEntity(seCourse), aData);
end;

function TSchoolBotPlugin.CreateInKbEditCourseTeacher(aCourseID: Integer
  ): TInlineKeyboard;
var
  aData: String;
  aUserStatus: TUserStatus;
begin
  Result:=CreateInKbEditCourseTeacherList(aCourseID);
  aUserStatus:=usTeacher;
  Result.Add.AddButtonInline(emj_New+' '+s_New+' ('+CaptionFromSchEntity(seTeacher)+')',
    dt_invitation+' '+aCourseID.ToString+' 1 '+UserStatusToString(aUserStatus));
  aData:=GetDataEdit(seCourse, aCourseID);
  Result.Add.AddButton(emj_ArrowUp+' '+CaptionFromSchEntity(seCourse), aData);
end;

function TSchoolBotPlugin.CreateInKbEditCourseTeacherList(aCourseID: Integer
  ): TInlineKeyboard;
var
  aTeacher: TStudentSpot;
  aUser: TUser;
begin
  Result:=TInlineKeyboard.Create;
  for aTeacher in CoursesDB.StudentSpots do
  begin
    aUser:=CoursesDB.GetUserByID(aTeacher.User);
    Result.Add.AddButton(aUser.Name, GetDataSet(seCourse, aCourseID, dt_teacher, aUser.id.ToString));
    Result.AddButton(emj_CrossMark+' '+s_Delete, GetDataDelete(seTeacher, aTeacher.ID));
  end;
end;

function TSchoolBotPlugin.CreateInKbEditTurn(aEntityType: TEntityType;
  aID: Int64; const aField: String): TInlineKeyboard;
begin
  Result:=TInlineKeyboard.Create;
  Result.AddButton(s_turnedOn,  GetDataSet(aEntityType, aID, aField, BoolToStr(True)),  2);
  Result.AddButton(s_turnedOff, GetDataSet(aEntityType, aID, aField, BoolToStr(False)), 2);
  Result.Add.AddButton(emj_ArrowUp+' '+s_Cancel, GetDataEdit(aEntityType, aID));
end;

function TSchoolBotPlugin.CreateInKbEditReplace(aEntityType: TEntityType;
  aID: Int64): TInlineKeyboard;
var
  aParentID: Int64;

  procedure AddButtonCourses;
  var
    aCourse: TCourse;
    i: Integer;
  begin
    for i:=1 to CoursesDB.Courses.Count do
    begin
      aCourse:=CoursesDB.Courses.Items[i-1];
      Result.AddButton(aCourse.Name, GetDataReplace(aEntityType, aID, aCourse.id), 2);
    end;
  end;
  procedure AddButtonLessons;
  var
    aLesson: TLesson;
    i: Integer;
  begin
    for i:=1 to CoursesDB.Lessons.Count do
    begin
      aLesson:=CoursesDB.Lessons.Items[i-1];
      Result.AddButton(aLesson.Name, GetDataReplace(aEntityType, aID, aLesson.id), 2);
    end;
  end;
  procedure AddButtonSlides;
  var
    aSlide: TSlide;
    i: Integer;
  begin
    for i:=1 to CoursesDB.Slides.Count do
    begin
      aSlide:=CoursesDB.Slides.Items[i-1];
      Result.AddButton(i.ToString+'. '+aSlide.Name, GetDataReplace(aEntityType, aID, aSlide.id), 2);
    end;
  end;

begin
  aParentID:=CoursesDB.CourseEntity[aEntityType].GetParentID;
  CoursesDB.FindEntitiesByParentID(aEntityType, aParentID, True);
  Result:=TInlineKeyboard.Create;
  case aEntityType of
    seCourse: AddButtonCourses;
    seLesson: AddButtonLessons;
    seSlide:  AddButtonSlides;
  else
    Exit;
  end;
  Result.Add.AddButton(emj_ArrowUp+' '+s_Cancel, GetDataEdit(aEntityType, aID));
end;

function TSchoolBotPlugin.CreateInKbEditInvitation(aInvitationID: Integer
  ): TInlineKeyboard;
var
  aCaption: String;
  aInvitation: TInvitation;
begin
  Result:=TInlineKeyboard.Create;
  aInvitation:=CoursesDB.GetInvitationByID(aInvitationID);
  aCaption:= emj_Share+' '+s_Share;
  Result.Add.AddButtonInline(aCaption, dt_invitation+' '+aInvitation.ID.ToString);
  aCaption:= emj_Teacher+' '+s_Teacher;
  Result.AddButton(aCaption, GetDataEdit(aInvitation, dt_teacher), 3);
  Result.AddButton(emj_CrossMark+' '+s_Delete, GetDataDelete(seInvitation, aInvitation.ID), 3);
  Result.Add.AddButton(emj_ArrowUp+' '+s_Invitations, GetDataList(seInvitation, aInvitation.Course));
end;

function TSchoolBotPlugin.CreateInKbEditInvitationTeacher(aInvitationID: Integer
  ): TInlineKeyboard;
var
  aTeacher: TStudentSpot;
  aCourseID, i: Integer;
begin
  aCourseID:=CoursesDB.GetInvitationByID(aInvitationID).Course;
  CoursesDB.FindEntitiesByParentID(seTeacher, aCourseID, True);
  Result:=TInlineKeyboard.Create;
  for i:=1 to CoursesDB.StudentSpots.Count do
  begin
    aTeacher:=CoursesDB.StudentSpots.Items[i-1];
    Result.AddButton(CoursesDB.GetUserByID(aTeacher.User).Name,
      GetDataSet(seInvitation, aInvitationID, dt_teacher, aTeacher.User.ToString), 2);
  end;
  Result.Add.AddButton(emj_ArrowUp+' '+s_Cancel, GetDataEdit(seInvitation, aInvitationID));
end;

function TSchoolBotPlugin.CreateInKbEditSlide(aSlideID: Integer
  ): TInlineKeyboard;
var
  aCaption: String;
  ParentID: Int64;
  aTurned: Boolean;
begin
  Result:=TInlineKeyboard.Create;
  Result.AddButton(s_Name, GetDataInput(seSlide, aSlideID, dt_name), 3);
  Result.AddButton(s_Content, GetDataInput(seSlide, aSlideID, dt_content), 3);
  aTurned:=CoursesDB.GetSlideByID(aSlideID).Interactive;
  aCaption:=s_Interactive+' ('+BoolToStr(aTurned, s_turnedOn, s_turnedOff)+')';
  Result.AddButton(aCaption, GetDataEdit(seSlide, aSlideID, dt_interactive), 3);
  ParentID:=CoursesDB.Slide.Lesson; // Lesson ID
  Result.Add;
  Result.AddButton(emj_ArrowUp+' '+s_Slides, GetDataList(seSlide, ParentID), 3);
  Result.AddButton(emj_Projector+' '+s_Demo, GetDataLaunch(seSlide, aSlideID), 3);
  Result.AddButton(emj_Shuffle+' '+s_Replace, GetDataEdit(seSlide, aSlideID, dt_replace), 3);
  Result.AddButton(emj_CrossMark+' '+s_Delete, GetDataEdit(seSlide, aSlideID, dt_delete), 3);
end;

function TSchoolBotPlugin.CreateInKbEditUser(aUserID: Int64
  ): TInlineKeyboard;
var
  aData: String;
begin
  Result:=TInlineKeyboard.Create;
  aData:=GetDataList(seCourse, aUserID);
  Result.AddButton(CaptionFromSchEntity(seCourse, True), aData, 2);
end;

function TSchoolBotPlugin.CreateInKbOpenDialog(aSessionID: Integer
  ): TInlineKeyboard;
var
  aData: String;
begin
  Result:=TInlineKeyboard.Create;
  aData:=GetDataLaunch(seSession, aSessionID);
  Result.AddButton(s_OpenDialog, aData, 2);
end;

function TSchoolBotPlugin.CreateReplyKeyboardStart: TReplyMarkup;
var
  aMenuItem: String;
begin
  Result:=TReplyMarkup.Create;
  Result.ResizeKeyboard:=True;
  Result.ReplyKeyboardMarkup:=TKeyboardButtonArray.Create;
  if AllCanCreateCourse or not Bot.CurrentIsSimpleUser then
    aMenuItem:=s_CourseCreation
  else
    aMenuItem:=s_StartMenu;
  if CoursesDB.GetSpotListByUser(Bot.CurrentChatId, usTeacher).Count>0 then
    Result.ReplyKeyboardMarkup.Add.AddButtons([aMenuItem, s_ITeacher])
  else
    Result.ReplyKeyboardMarkup.Add.AddButtons([aMenuItem, s_IStudent]);
  Result.ReplyKeyboardMarkup.Add.AddButtons([s_Help, s_Storage, s_Settings]);
end;

function TSchoolBotPlugin.CreateReplyKeyboardDialogSession: TKeyboardButtonArray;
begin
  Result:=TKeyboardButtonArray.Create;
  Result.Add.AddButtons([s_DialogExit]);
end;

procedure TSchoolBotPlugin.DataFieldSet(aEntityType: TEntityType; aID: Int64;
  const aField: String; const aValue: String; aMessage: TTelegramMessageObj);
begin
  if (aID=0) and (aEntityType=seUser) then
    aID:=Bot.CurrentChatId;
  CoursesDB.GetEntityByID(aEntityType, aID);
  case AnsiIndexStr(aField,
    [dt_name, dt_content, dt_access, dt_interactive, dt_contact, dt_showcontact, dt_text,
    dt_teacher, dt_testing, dt_lesson, dt_historychat]) of
    0: CoursesDB.SchoolEntity[aEntityType].Name:=aValue;
    1: SetEntityContent(aMessage, CoursesDB.CourseEntity[aEntityType]);
    2: CoursesDB.Course.LicType:=TLicType(StrToInt(aValue));
    3: CoursesDB.CourseEntity[aEntityType].Interactive:=StrToBool(aValue);
    4: CoursesDB.Course.Contact:=aValue;
    5: CoursesDB.Course.ShowContact:=StrToBoolDef(aValue, False);
    6: CoursesDB.CourseEntity[aEntityType].Text:=aValue;
    7: CoursesDB.SchoolEntity[aEntityType].Teacher:=StrToIntDef(aValue, 0);
    8: CoursesDB.Course.Testing:=StrToBoolDef(aValue, False);
    9: SendEditAcceptTeacher(StrToIntDef(aValue, 0));
    10: CoursesDB.Course.HistoryChat:=Trim(aValue);
  end;
  CoursesDB.SaveCourseEntity(aEntityType);
  if aEntityType in [seStudentSpot..seTeacher] then
    Exit;
  if (aEntityType=seCourse) and (CoursesDB.Course.Owner=Bot.CurrentUser.ID) then
    SaveCurrentUser;
  SendEditMessage(aEntityType, aID);
end;

procedure TSchoolBotPlugin.DataFieldSet(const aData: String;
  aMessage: TTelegramMessageObj);
var
  aEntity: TEntityType;
  aID: Int64;
  aField, aValue, s: String;
begin
  s:=ExtractWord(2, aData, [' ']);
  if s<>EmptyStr then
    aEntity:=EntityFromString(s)
  else
    aEntity:=seCourse;
  if aEntity=seUnknown then
    Exit;
  aID:=StrToInt64Def(ExtractWord(3, aData, [' ']), 0);
  aField:=ExtractWord(4, aData, [' ']);
  aValue:=ExtractWord(5, aData, [' ']);
  DataFieldSet(aEntity, aID, aField, aValue, aMessage);
end;

function TSchoolBotPlugin.GetCoursesDB: TopCoursesDB;
begin
  if not Assigned(FCoursesDB) then
  begin
    FCoursesDB:=TopCoursesDB.Create;
    FCoursesDB.DBDir:=AppDir+Bot.BotUsername+PathDelim;
    FCoursesDB.LogDebug:=Bot.LogDebug;
    FCoursesDB.Logger:=Bot.Logger;
  end;
  Result:=FCoursesDB;
end;

function TSchoolBotPlugin.GetUserFromCurrentChatId: TUser;
var
  aName: String;
begin
  if Assigned(Bot.CurrentChat) then
    aName:=CaptionFromChat(Bot.CurrentChat)
  else
    if Assigned(Bot.CurrentUser) then
      aName:=CaptionFromUser(Bot.CurrentUser)
    else
      aName:='Unknown name';
  Result:=CoursesDB.GetUserByID(Bot.CurrentChatId);
  Result.Name:=aName;
end;

function TSchoolBotPlugin.CheckParents(aEntityType: TEntityType; aID: Int64;
  out aParentID: Int64): Boolean;
begin
  Result:=False;
  aParentID:=aID;
  if aEntityType=seInvitation then
    aParentID:=CoursesDB.GetInvitationByID(aParentID).Course
  else begin
    if aEntityType=seSlide then
      aParentID:=CoursesDB.GetSlideByID(aParentID).Lesson;
    if aParentID=0 then Exit;
    if aEntityType>=seLesson then
      aParentID:=CoursesDB.GetLessonByID(aParentID).Course;
  end;
  if aParentID=0 then Exit;
  if aEntityType>=seCourse then
    aParentID:=CoursesDB.GetCourseByID(aParentID).Owner;
  if aParentID=0 then Exit;
  if aEntityType>=seUser then
    if aParentID=Bot.CurrentUser.ID then
      Exit(True);

end;

function TSchoolBotPlugin.CheckChannelMember(aChat: Int64; aUser: Int64
  ): Boolean;
var
  aChatMember: TTelegramChatMember;
begin
  Bot.getChatMember(aChat, aUser, aChatMember);
  Result:=aChatMember.is_member;
  if not Result then
    Result:=aChatMember.StatusType<=msRestricted;
  aChatMember.Free;
end;

function TSchoolBotPlugin.InlnKybrd4StngsLang(aInlineKeyboard: TInlineKeyboard;
  aLangList: TStrings; const LCode, aSetLangCmd: String): Boolean;
var
  aBtn: TInlineKeyboardButton;
  aCaption, s: String;
begin
  Result:=False;
  for s in aLangList do
  begin
    aCaption:= CaptionFromLangCode(s);
    if AnsiSameStr(LCode, s) then
    begin
      aCaption:=emj_TurnedOn+' '+aCaption;
      Result:=True;
    end;
    aBtn:=TInlineKeyboardButton.Create(aCaption);
    aBtn.callback_data:=aSetLangCmd+' '+s;
    aInlineKeyboard.AddButton(aBtn, 2);
  end;
end;

procedure TSchoolBotPlugin.HandleStart(const aParameter: String);
var
  aReplyMarkup: TReplyMarkup;
begin
  if aParameter<>EmptyStr then
  begin
    Bot.DoReceiveDeepLinking(aParameter);
    Exit;
  end;
  aReplyMarkup:=CreateReplyKeyboardStart;
  try
    Bot.sendMessage(s_StartText, pmMarkdown, True, aReplyMarkup);
  finally
    AReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.HandleHelp;
var
  aReplyMarkup: TReplyMarkup;
begin
  aReplyMarkup:=CreateReplyKeyboardStart;
  try
    Bot.sendMessage(s_HelpText, pmMarkdown, True, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.QueryResultsLaunch(const aData: String;
  const aQueryID: String);
var
  aID, aCapacity: LongInt;
  aEntityType: TEntityType;
  aUserStatus: TUserStatus;
  aResults: TInlineQueryResultArray;
  aEntity: TCourseElement;
  aCacheTime: Integer;
begin
  aCacheTime:=1000;
  aEntityType:=EntityFromString(ExtractWord(1, aData, [' ']));
  aID:=StrToIntDef(ExtractWord(2, aData, [' ']), 0);
  if (aEntityType=seUnknown) and (aData<>EmptyStr) then
    Exit;
  aCapacity:=StrToIntDef(ExtractWord(3, aData, [' ']), 0);
  aUserStatus:=StringToUserStatus(ExtractWord(4, aData, [' ']));
  if aUserStatus=usUnknown then
    aUserStatus:=usStudent;
  aResults:=TInlineQueryResultArray.Create;
  try
    if (aEntityType=seInvitation) and (aCapacity>0) then
    begin
      aID:=CoursesDB.NewInvitation(aID, aCapacity, aUserStatus);
      aCacheTime:=3;
    end;
    aResults.Add(CreateQryResultLaunch(aEntityType, aID));
    if aData=EmptyStr then
      for aEntity in CoursesDB.GetCoursesList(Bot.CurrentChatId) do
        aResults.Add(CreateQryResultLaunch(seCourse, aEntity.id));
    {%H-}
    case aEntityType of
      seCourse: for aEntity in CoursesDB.Lessons do aResults.Add(CreateQryResultLaunch(Succ(aEntityType), aEntity.id));
      seLesson: for aEntity in CoursesDB.Slides do aResults.Add(CreateQryResultLaunch(Succ(aEntityType), aEntity.id));
    end;
    Bot.answerInlineQuery(aQueryID,  aResults, aCacheTime);
  finally
    aResults.Free;
  end;
end;

procedure TSchoolBotPlugin.QueryResultsFindNewBot(const aQueryID: String);
var
  aResults: TInlineQueryResultArray;
  aCacheTime: Integer;
  aQueryResult: TInlineQueryResult;
begin
  aCacheTime:=60000;
  aResults:=TInlineQueryResultArray.Create;
  try
    aQueryResult:=TInlineQueryResult.Create;
    with aQueryResult do
    begin
      ID:='FindNewBot_reply';
      IQRType:=qrtArticle;
      Caption:='The bot is working!';
      InputMessageContent:=TInputMessageContent.Create('Ok. The bot is working!');
      Title:='Answer for @FindNewBot';
    end;
    aResults.Add(aQueryResult);
    Bot.answerInlineQuery(aQueryID,  aResults, aCacheTime);
  finally
    aResults.Free;
  end;
end;

procedure TSchoolBotPlugin.ReplyToCommandMessage(AMessage: TTelegramMessageObj);
var
  S: String;
  i: SizeInt;
  aEntity: TEntityType;
  aID: Int64;
  aFound: Boolean;
begin
  S:=AMessage.ReplyToMessage.Text;
  i:=Pos(LineEnding, S);
  if i=0 then
  begin
    Bot.Logger.Error('No LineEnding found!');
    Exit;
  end;
  S:=LeftStr(S, i-1);
  if S[1]='/' then
  begin
    if AnsiStartsStr('/'+'feedback', S) then
      Exit;
    Bot.UpdateProcessed:=True;
    try
      if AnsiStartsStr('/'+dt_NewCourse, S) then
      begin
        SaveNewCourse(Bot.CurrentChatId, AMessage.Text);
        Exit;
      end;
      aEntity:=EntityFromString(ExtractWord(2, S, [' ']));
      aID:=StrToInt64Def(ExtractWord(3, S, [' ']), 0);
      if aEntity=seUser then
      begin
        Bot.Logger.Error('Can''t create new user. Unavailable operation!');
        Exit;
      end;
      if AnsiStartsStr('/'+dt_new, S) then
      begin
        if not CheckRights(Pred(aEntity), aID, aFound) then
        begin
          Bot.sendMessage(s_NotFound);
          Exit;
        end;
        case aEntity of
          seCourse:     SaveNewCourse(aID, AMessage.Text);
          seLesson:     SaveNewLesson(aID, AMessage.Text);
          seSlide:      SaveNewSlide(aID, AMessage);
          seInvitation: SaveNewInvitation(aID, AMessage.Text);
        else
          Bot.Logger.Error('Unexpected entity type while SaveNew...');
        end;
        Exit;
      end;
      if AnsiStartsStr('/'+dt_edit, S) then
      begin
        if not CheckRights(aEntity, aID, aFound) then
        begin
          Bot.sendMessage(s_NotFound);
          Exit;
        end;
        SchoolEntitySetField(aEntity, aID, ExtractWord(4, S, [' ']), AMessage.Text, aMessage);
      end;
      if AnsiStartsStr('/'+dt_set, S) then
      begin
        if not CheckRights(aEntity, aID, aFound) then
        begin
          Bot.sendMessage(s_NotFound);
          Exit;
        end;
        SchoolEntitySetField(aEntity, aID, ExtractWord(4, S, [' ']), AMessage.Text, aMessage);
      end;
    finally
      Bot.deleteMessage(AMessage.ReplyToMessage.MessageId);
      Bot.deleteMessage(AMessage.MessageId);
    end;
  end;
end;

function TSchoolBotPlugin.HandleLaunchCourse(aCourseID: Integer; out
  aText: String; out aParseMode: TParseMode; aReplyMarkup: TReplyMarkup; out
  aContentType: TContentType; out aMedia: String): Boolean;
var
  aCount: Integer;
begin
  aContentType:=stText;
  aParseMode:=pmMarkdown;
  Result:=False;
  if not CheckLicRights(seCourse, aCourseID) then
  begin
    aText:=s_NotFound;
    Exit;
  end;
  if not CheckIsTested(seCourse) then
  begin
    aText:=s_NotPassed;
    Exit;
  end;
  CoursesDB.GetLessonsList(aCourseID);
  aReplyMarkup.InlineKeyBoard:=CreateInKbLaunchCourse;
  aText:=s_Course+': *'+CoursesDB.GetCourseByID(aCourseID).Name+'*';
  if CoursesDB.Course.Text<>EmptyStr then
    aText+=LineEnding+MarkdownEscape(CoursesDB.Course.Text);
  aCount:=CoursesDB.Lessons.Count;
  if aCount=0 then
    aText+=LineEnding+s_WhileNoLessons
  else
    aText+=LineEnding+s_LessonCount+': *'+aCount.ToString+'*';
  aContentType:=CoursesDB.Course.MediaType;
  aMedia:=CoursesDB.Course.Media;
  aParseMode:=pmMarkdown;
  Result:=True;
end;

function TSchoolBotPlugin.HandleLaunchLesson(aLessonID: Integer; out
  aText: String; out aParseMode: TParseMode; aReplyMarkup: TReplyMarkup; out
  aContentType: TContentType; out aMedia: String): Boolean;
var
  aCount: LongInt;
begin
  Result:=False;
  aContentType:=stText;
  aParseMode:=pmMarkdown;
  if not CheckLicRights(seLesson, aLessonID) then
  begin
    aText:=s_NotFound;
    Exit;
  end;
  if not CheckIsTested(seLesson) then
  begin
    aText:=s_NotPassed;
    Exit;
  end;
  CoursesDB.GetSlidesList(aLessonID);
  aReplyMarkup.InlineKeyBoard:=CreateInKbLaunchLesson;
  aText:=s_Lesson+': *'+MarkdownEscape(CoursesDB.GetLessonByID(aLessonID).Name)+'*';
  if CoursesDB.Lesson.Text<>EmptyStr then
    aText+=LineEnding+MarkdownEscape(CoursesDB.Lesson.Text);
  aCount:=CoursesDB.Slides.Count;
  if aCount=0 then
    aText+=LineEnding+s_WhileNoSlides
  else
    aText+=LineEnding+s_SlideCount+': '+aCount.ToString;
  aText+=LineEnding+mdCode+s_Course+': '+MarkdownEscape(CoursesDB.Course.Name)+mdCode;
  aContentType:=CoursesDB.Lesson.MediaType;
  aMedia:=CoursesDB.Lesson.Media;
  Result:=True;
end;

function TSchoolBotPlugin.HandleLaunchSlide(aSlideID: Integer; out
  aText: String; out aParseMode: TParseMode; aReplyMarkup: TReplyMarkup; out
  aContentType: TContentType; out aMedia: String): Boolean;
begin
  Result:=False;
  aParseMode:=pmMarkdown;
  aContentType:=stText;
  if not CheckLicRights(seSlide, aSlideID) then
  begin
    aText:=s_NotFound;
    Exit;
  end;
  if not CheckIsTested(seSlide) then
  begin
    aText:=s_NotPassed;
    Exit;
  end;
  aReplyMarkup.InlineKeyBoard:=CreateInKbLaunchSlide(aSlideID);
  aText:=CoursesDB.Slide.Text;
  aContentType:=CoursesDB.Slide.MediaType;
  aMedia:=CoursesDB.Slide.Media;
  aParseMode:=pmDefault;
  Result:=True;
end;

procedure TSchoolBotPlugin.HandleDelete(const aData: String);
var
  aID: Int64;
  aEntityType: TEntityType;
begin
  aEntityType:=EntityFromString(ExtractWord(2, aData, [' ']));
  aID:=StrToInt64Def(ExtractWord(3, aData, [' ']), 0);
  HandleDelete(aEntityType, aID);
end;

procedure TSchoolBotPlugin.HandleDelete(aEntityType: TEntityType; aID: Int64);
var
  aParentID: Int64;
  aFound: Boolean;
begin
  if not CheckRights(aEntityType, aID, aFound) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  CoursesDB.GetEntityByID(aEntityType, aID);
  case aEntityType of
    seCourse..seSlide:
              aParentID:=CoursesDB.CourseEntity[aEntityType].GetParentID;
    seInvitation: aParentID:=CoursesDB.Invitation.Course;
    seStudentSpot..seTeacher:
                  aParentID:=CoursesDB.StudentSpot.Course;
  else
    aParentID:=0;
  end;
  CoursesDB.DeleteCourseEntity(aEntityType);
  SendList(aEntityType, aParentID);
end;

procedure TSchoolBotPlugin.OpenSession(aSessionID: Integer);
var
  aReplyMarkup: TReplyMarkup;
  aText: String;
  aSession: TSession;
  aEntity: TEntityType;
begin
  aSession:=CoursesDB.GetSessionByID(aSessionID);
  aEntity:=aSession.GetSourceEntityType;
  if not CheckLicRights(aEntity, aSession.EntityID) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  if not CheckIsTested(aEntity) then
  begin
    Bot.sendMessage(s_NotPassed);
    Exit;
  end;
  aText:=s_StartDialog;
  if aEntity>=seCourse then
    aText+=LineEnding+s_Course+': '+CoursesDB.Course.Name;
  if aEntity>=seLesson then
    aText+=LineEnding+s_Lesson+': '+CoursesDB.Lesson.Name;
  if aEntity>=seSlide then
  begin
    CoursesDB.GetSlidesList(CoursesDB.Lesson.id);
    aText+=LineEnding+s_Slide+': №'+(CoursesDB.GetSlideIndexByID(CoursesDB.Slide.id)+1).ToString;
  end;
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.ReplyKeyboardMarkup:=CreateReplyKeyboardDialogSession;
    aReplyMarkup.ResizeKeyboard:=True;
    Bot.deleteMessage(Bot.CurrentMessage.MessageId);
    GetUserFromCurrentChatId.Session:=aSessionID;
    CoursesDB.SaveUser;
    Bot.SendMessage(aText, pmMarkdown, False, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

function TSchoolBotPlugin.HandleSendInvitation(aInvitationID: Integer; out
  aText: String; out aParseMode: TParseMode; aReplyMarkup: TReplyMarkup;
  out aContentType: TContentType; out aMedia: String): Boolean;
var
  aFound: Boolean;
begin
  Result:=False;
  CoursesDB.GetInvitationByID(aInvitationID);
  if not CheckRights(seInvitation, aInvitationID, aFound) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  aText:=s_InvitationText;
  with CoursesDB do
  begin
    if Invitation.UserStatus=usTeacher then
      aText+=' *'+s_ForTeacher+'*';
    aText+=': ';
    aText+=LineEnding+'*'+GetCourseByID(Invitation.Course).Name+'*'+LineEnding;
    if Course.Text<>EmptyStr then
      aText+=LineEnding+Course.Text+LineEnding;
    aMedia:=Course.Media;
    aContentType:=Course.MediaType;
  end;
  aReplyMarkup.InlineKeyBoard:=CreateInKbInvitation(aInvitationID);
  aParseMode:=pmMarkdown;
  Result:=True;
end;

procedure TSchoolBotPlugin.SaveCurrentUser;
begin
  GetUserFromCurrentChatId;
  CoursesDB.SaveUser;
end;

procedure TSchoolBotPlugin.SendLaunch(const aData: String);
var
  aID: LongInt;
  aEntityType: TEntityType;
begin
  aEntityType:=EntityFromString(ExtractWord(2, aData, [' ']));
  aID:=StrToIntDef(ExtractWord(3, aData, [' ']), 0);
  if aEntityType<>seSession then
    SendLaunch(aEntityType, aID)
  else
    OpenSession(aID);
end;

procedure TSchoolBotPlugin.SendLaunch(aEntityType: TEntityType; aID: Int64);
var
  aReplyMarkup: TReplyMarkup;
  aMsg, aMedia: String;
  aParseMode: TParseMode;
  aContentType: TContentType;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aContentType:=stText;
    case aEntityType of
      seCourse:     HandleLaunchCourse(aID, aMsg, aParseMode, aReplyMarkup, aContentType, aMedia);
      seLesson:     HandleLaunchLesson(aID, aMsg, aParseMode, aReplyMarkup, aContentType, aMedia);
      seSlide:      HandleLaunchSlide(aID, aMsg, aParseMode, aReplyMarkup, aContentType, aMedia);
      seInvitation: HandleSendInvitation(aID, aMsg, aParseMode, aReplyMarkup, aContentType, aMedia);
    else
      Exit;
    end;
    if (aEntityType<>seInvitation) and (CoursesDB.Course.LicType<ltPrivate) then
      aReplyMarkup.InlineKeyBoard.Add.AddButtonInline(emj_Share+' '+s_Share,
        EntityTypeToString(aEntityType)+' '+aID.ToString);
    if aEntityType in [seCourse, seLesson] then
      if CoursesDB.CourseEntity[aEntityType].Interactive then
        aReplyMarkup.InlineKeyBoard.AddButton(emj_Teacher+' '+s_TestOrAsk,
          GetDataNewSession(aEntityType, aID), 2);
    BotSendEntityContent(aMsg, aMedia, aContentType, aParseMode, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditMessage(const aData: String);
var
  aEntity: TEntityType;
  aID: Int64;
  s: String;
begin
  s:=ExtractWord(2, aData, [' ']);
  if s<>EmptyStr then
    aEntity:=EntityFromString(s)
  else
    aEntity:=seCourse;
  if aEntity=seUnknown then
    Exit;
  aID:=StrToInt64Def(ExtractWord(3, aData, [' ']), 0);
  SendEditMessage(aEntity, aID, ExtractWord(4, aData, [' ']));
end;

procedure TSchoolBotPlugin.SendEditMessage(aEntityType: TEntityType; aID: Int64;
  const aField: String);
var
  aReplyMarkup: TReplyMarkup;
  aFound: Boolean;

  procedure SendUserEdit;
  var
    aMsg: String;
    aCount: Integer;
  begin
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditUser(aID);
    aMsg:=s_User+': “'+MarkdownEscape(CoursesDB.SchoolEntity[aEntityType].Name)+'”'+LineEnding+
      mdCode+'ID: '+aID.ToString+mdCode;
    aCount:=CoursesDB.Courses.Count;
    if aCount=0 then
      aMsg+=LineEnding+s_UserNotHaveCourses
    else
      aMsg+=LineEnding+s_CourseCount+': *'+aCount.ToString+'*';
    Bot.EditOrSendMessage(aMsg, pmMarkdown, aReplyMarkup, True);
  end;
  procedure SendEntityEdit(aEntity: TCourseElement; const aMsg: String; aParseMode: TParseMode);
  begin
    case aEntity.EntityType of
      seCourse:     aReplyMarkup.InlineKeyBoard:=CreateInKbEditCourse(aID);
      seLesson:     aReplyMarkup.InlineKeyBoard:=CreateInKbEditLesson(aID);
      seSlide:      aReplyMarkup.InlineKeyBoard:=CreateInKbEditSlide(aID);
    else
      Bot.Logger.Error('Unknown EntityType while for SendEntityEdit');
    end;
    BotSendEntityContent(aMsg, aEntity.Media, aEntity.MediaType, aParseMode, aReplyMarkup);
  end;
  procedure SendCourseEdit;
  var
    aMsg, aContact: String;
    aCount: Integer;
  begin
    aMsg:=s_Course+' *“'+MarkdownEscape(CoursesDB.Course.Name)+'”*';
    if CoursesDB.Course.Text<>EmptyStr then
      aMsg+=LineEnding+MarkdownEscape(CoursesDB.Course.Text);
    aCount:=CoursesDB.Lessons.Count;
    aMsg+=LineEnding+s_LessonCount+': *'+aCount.ToString+'*';
    aMsg+=LineEnding+s_Access+': *'+LicTypeToCaption(CoursesDB.Course.LicType)+'*';
    aMsg+=LineEnding+s_InteractiveButton+': *'+
      BoolToStr(CoursesDB.Course.Interactive, s_turnedOn, s_turnedOff)+'*'+' _('+s_CommunicationViaBot+')_';
    aContact:=CoursesDB.Course.Contact;
    if aContact=EmptyStr then
      aContact:='_Course''s author_'
    else
      aContact:='*'+aContact+'*';
    aMsg+=LineEnding+s_ContactLink+': '+aContact+' _('+s_CommunicationContact+')_';
    aMsg+=LineEnding+s_ContactButton+': *'+BoolToStr(CoursesDB.Course.ShowContact,
      s_turnedOn, s_turnedOff)+'*';
    aMsg+=LineEnding+s_WithTesting+': *'+
      BoolToStr(CoursesDB.Course.Testing, s_turnedOn, s_turnedOff)+'*';
    if CoursesDB.Course.Teacher<>0 then
      aMsg+=LineEnding+s_Teacher+': '+
        '['+CoursesDB.GetUserByID(CoursesDB.Course.Teacher).Name+'](](tg://user?id='+
        CoursesDB.Course.Teacher.ToString+')'+LineEnding;
    aMsg+=LineEnding+mdCode+'ID: '+aID.ToString+mdCode;
    SendEntityEdit(CoursesDB.Course, aMsg, pmMarkdown);
  end;
  procedure SendLessonEdit;
  var
    aMsg: String;
    aCount: Integer;
  begin
    aMsg:=s_Lesson+' *“'+MarkdownEscape(CoursesDB.Lesson.Name)+'”*';
    if CoursesDB.Lesson.Text<>EmptyStr then
      aMsg+=LineEnding+MarkdownEscape(CoursesDB.Lesson.Text);
    aCount:=CoursesDB.Slides.Count;
    aMsg+=LineEnding+s_SlideCount+': *'+aCount.ToString+'*';
    aMsg+=LineEnding+s_Interactive+': *'+
      BoolToStr(CoursesDB.Lesson.Interactive, s_turnedOn, s_turnedOff)+'*';
    aMsg+=LineEnding+mdCode+'ID: '+aID.ToString+mdCode;
    SendEntityEdit(CoursesDB.Lesson, aMsg, pmMarkdown);
  end;
  procedure SendSlideEdit;
  begin
    SendEntityEdit(CoursesDB.Slide, CoursesDB.Slide.Text, pmDefault);
  end;
  procedure SendInvitationEdit;
  var
    aMsg: String;
  begin
    aMsg:=s_InvitationText;
    with CoursesDB do
    begin
      if Invitation.UserStatus=usTeacher then
        aMsg+=' *'+s_ForTeacher+'*';
      aMsg+=': ';
      aMsg+=LineEnding+s_Name+': *'+GetCourseByID(Invitation.Course).Name+'*'+LineEnding;
      if Course.Text<>EmptyStr then
        aMsg+=LineEnding+Course.Text+LineEnding;
      if Invitation.Teacher<>0 then
        aMsg+=LineEnding+s_Teacher+': '+
          '['+GetUserByID(Invitation.Teacher).Name+'](](tg://user?id='+
          Invitation.Teacher.ToString+')'+LineEnding;
      aMsg+=LineEnding+mdCode+'ID: '+aID.ToString+mdCode;
    end;
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditInvitation(aID);
    Bot.EditOrSendMessage(aMsg, pmMarkdown, aReplyMarkup, True);
  end;

begin
  CoursesDB.GetEntityByID(aEntityType, aID);
  if not CheckRights(aEntityType, aID, aFound) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  if aField<>EmptyStr then
  begin
    if aEntityType=seCourse then
      case AnsiIndexStr(aField, [dt_access, dt_invitation, dt_showcontact, dt_testing, dt_teacher, dt_student]) of
        0: SendEditCourseLicense(aID);
        1: SendEditCourseInvitations(aID);
        2: SendEditContactButton(aID);
        3: SendEditTesting(aID);
        4: SendEditCourseTeacher(aID);
        5: SendEditCourseStudents(aID);
      end;
    if aEntityType in [seCourse..seSlide] then
      case AnsiIndexStr(aField, [dt_replace, dt_interactive]) of
        0: SendEditReplace(aEntityType, aID);
        1: SendEditInteractive(aEntityType, aID);
      end;
    if aEntityType=seInvitation then
      case AnsiIndexStr(aField, [dt_teacher]) of
        0: SendEditInvitationTeacher(aID);
      end;
    if aField=dt_delete then
      SendEditDelete(aEntityType, aID);
  end
  else begin
    aReplyMarkup:=TReplyMarkup.Create;
    try
      CoursesDB.FindEntitiesByParentID(Succ(aEntityType), aID, True);
      case aEntityType of
        seUser:        SendUserEdit;
        seCourse:      SendCourseEdit;
        seLesson:      SendLessonEdit;
        seSlide:       SendSlideEdit;
        seInvitation:  SendInvitationEdit;
      else
        Bot.Logger.Error('Unexpected entity type while SendEditMessage');
      end;
    finally
      aReplyMarkup.Free;
    end;
  end;
end;

procedure TSchoolBotPlugin.SendEditReplace(aEntityType: TEntityType; aID: Int64);
var
  aReplyMarkup: TReplyMarkup;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditReplace(aEntityType, aID);
    Bot.EditOrSendMessage(s_SelectToSwap, pmMarkdown, aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendEditTesting(aID: Integer);
var
  aReplyMarkup: TReplyMarkup;
  aTurnedOn: Boolean;
begin
  aReplyMarkup:=TReplyMarkup.Create;
  try
    CoursesDB.GetCourseByID(aID);
    aTurnedOn:=CoursesDB.Course.Testing;
    aReplyMarkup.InlineKeyBoard:=CreateInKbEditTurn(seCourse, aID, dt_testing);
    Bot.EditOrSendMessage(emj_CheckBox+' '+s_WithTesting+': *'+
      BoolToStr(aTurnedOn, s_turnedOn, s_turnedOff)+'*'+LineEnding+s_TestingDescription, pmMarkdown,
      aReplyMarkup, True);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.BotSendEntityContent(const aText, aMedia: String;
  aMediaType: TContentType; aParseMode: TParseMode; aReplyMarkup: TReplyMarkup);
var
  aMsgID: Integer;
begin
  aMsgID:=0;
  if Bot.CurrentUpdate.UpdateType=utCallbackQuery then
    if Assigned(Bot.CurrentMessage) then
      aMsgID:=Bot.CurrentMessage.MessageId;
  case aMediaType of
    stText:  Bot.sendMessage(aText, aParseMode, True, aReplyMarkup);
    stPhoto: Bot.sendPhoto(aMedia, aText, aParseMode, aReplyMarkup);
    stAudio: Bot.SendAudio(Bot.CurrentChatId, aMedia, aText, aParseMode, 0, False, 0, EmptyStr,
      EmptyStr, aReplyMarkup);
    stVideo: Bot.sendVideo(aMedia, aText, aParseMode, aReplyMarkup);
    stVoice: Bot.sendVoice(Bot.CurrentChatId, aMedia, aText, aParseMode, 0, False, 0, aReplyMarkup);
    stDocument: Bot.sendDocument(Bot.CurrentChatId, aMedia, aText, aParseMode, False, 0,
      aReplyMarkup);
  else
    Bot.Logger.Error('Unknown entity content type '+aMedia+'!');
  end;
  if aMsgID<>0 then
    Bot.deleteMessage(aMsgID);
end;

procedure TSchoolBotPlugin.SendInput(const aData: String);
var
  aEntity: TEntityType;
  aID: Int64;
  aField: String;
begin
  aEntity:=EntityFromString(ExtractWord(2, aData, [' ']));
  if aEntity=seUnknown then
    Exit;
  aID:=StrToInt64Def(ExtractWord(3, aData, [' ']), 0);
  if aID=0 then
    Exit;
  aField:=ExtractWord(4, aData, [' ']);
  if aField=EmptyStr then
    Exit;
  SendInput(aEntity, aID, aField);
end;

procedure TSchoolBotPlugin.SendInput(aEntity: TEntityType; aID: Int64;
  const aField: String);
var
  aReplyMarkup: TReplyMarkup;
  s: String;
  aFound: Boolean;
begin
  if not CheckRights(aEntity, aID, aFound) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  aReplyMarkup:=TReplyMarkup.Create;
  aReplyMarkup.ForceReply:=True;
  try
    s:='/'+dt_set+' '+EntityTypeToString(aEntity)+' '+aID.ToString+' '+aField+LineEnding+
      CaptionInputValue(aField);
    Bot.sendMessage(s, pmMarkdown, True, aReplyMarkup);
  finally
    aReplyMarkup.Free;
  end;
end;

procedure TSchoolBotPlugin.SendList(const aData: String);
var
  aEntity: TEntityType;
  aID: Int64;
  s, aParameter: String;
begin
  s:=ExtractWord(2, aData, [' ']);
  if s<>EmptyStr then
    aEntity:=EntityFromString(s)
  else
    aEntity:=seCourse;
  if aEntity=seUnknown then
    Exit;
  aID:=StrToInt64Def(ExtractWord(3, aData, [' ']), 0);
  aParameter:=ExtractWord(4, aData, [' ']);
  SendList(aEntity, aID, aParameter=dt_csv);
end;

procedure TSchoolBotPlugin.SendList(aEntity: TEntityType; aID: Int64; aCSV: Boolean);
var
  aReplyMarkup: TReplyMarkup;
  aCount: Integer;
  aFound, IsCourseOwner: Boolean;
  aParentEntity: TEntityType;
  aMsg: String;
begin
  IsCourseOwner:=aID<>0;
  if (aEntity in [seCourse, seStudentSpot..seTeacher]) and (aID=0) then
    aID:=Bot.CurrentChatId;
  if aEntity in [seInvitation, seStudentSpot..seTeacher] then
    aParentEntity:=seCourse
  else
    aParentEntity:=Pred(aEntity);
  if (not IsCourseOwner) and (aEntity in [seStudentSpot..seTeacher]) then
    aParentEntity:=seUser;
  if not CheckRights(aParentEntity, aID, aFound) then
  begin
    Bot.sendMessage(s_NotFound);
    Exit;
  end;
  aCount:=CoursesDB.FindEntitiesByParentID(aEntity, aID, IsCourseOwner);
  if aCSV then
    SendListStudentsCSVFromCourse
  else
    begin
      aReplyMarkup:=TReplyMarkup.Create;
      try
        aReplyMarkup.InlineKeyBoard:=CreateInKbList(aEntity, aID, IsCourseOwner);
        if (aEntity in [seStudentSpot..seTeacher]) and not IsCourseOwner then
        begin
          case aEntity of
            seStudent:     aMsg:=s_YStudent;
            seTeacher:     aMsg:=s_YTeacher;
          else
            aMsg:='*'+s_Courses+'*'+' ('+aCount.ToString+')';
          end;
        end
        else
          aMsg:='*'+CaptionFromSchEntity(aEntity, True)+'*'+' ('+aCount.ToString+')';
        if aParentEntity>seUser then
        begin
          aMsg+=LineEnding+mdCode;
          aMsg+=s_Course+': '+CoursesDB.Course.Name;
          if aParentEntity>seCourse then
            aMsg+=' | '+s_Lesson+': '+CoursesDB.Lesson.Name;
          aMsg+=mdCode;
        end;
        Bot.EditOrSendMessage(aMsg, pmMarkdown, aReplyMarkup, True);
      finally
        aReplyMarkup.Free;
      end;
    end;
end;

procedure TSchoolBotPlugin.SendListStudentsCSVFromCourse;
var
  aCSVStream: TMemoryStream;
begin
  aCSVStream:=TMemoryStream.Create;
  try
    CoursesDB.StudentsToSCVDocument(aCSVStream);
    Bot.sendDocumentStream(Bot.CurrentChatId, EntityTypeToString(seStudent)+'.csv', aCSVStream,
      CaptionFromSchEntity(seStudent, True)+' '+dt_csv);
  finally
    aCSVStream.Free;
  end;
end;

procedure TSchoolBotPlugin.SetLang(const aLangCode: String);
begin
  CoursesDB.GetUserByID(Bot.CurrentChatId);
  CoursesDB.User.Lang:=aLangCode;
  SaveCurrentUser;
end;

procedure TSchoolBotPlugin.SetEntityContent(aMessage: TTelegramMessageObj;
  aEntity: TCourseElement);
var
  aText, aMedia: String;
begin
  aEntity.MediaType:= ContentFromMessage(aMessage, aText, aMedia);
  {%H-}aEntity.Text:= aText;
  aEntity.Media:=     aMedia;
end;

constructor TSchoolBotPlugin.Create;
begin
  inherited Create;
  FAllCanCreateCourse:=True;
  Bot.CommandHandlers['/newcourse']:=@BotCommandNewCourse;
  Bot.CommandHandlers['/'+dt_list]:=@BotCommandList;
  Bot.CommandHandlers['/'+dt_edit]:=@BotCommandEdit;
  Bot.CommandHandlers['/'+dt_launch]:=@BotCommandLaunch;
  Bot.CommandHandlers['/'+dt_set]:=@BotCommandSet;
  Bot.CallbackHandlers[dt_SetLang]:=@BotCallbackSetLang;
  Bot.CallbackHandlers[dt_new]:=@BotCallbackNew;
  Bot.CallbackHandlers[dt_list]:=@BotCallbackList;
  Bot.CallbackHandlers[dt_edit]:=@BotCallbackEdit;
  Bot.CallbackHandlers[dt_input]:=@BotCallbackInput;
  Bot.CallbackHandlers[dt_launch]:=@BotCallbackLaunch;
  Bot.CallbackHandlers[dt_delete]:=@BotcallbackDelete;
  Bot.CallbackHandlers[dt_set]:=@BotCallbackSet;
  Bot.CallbackHandlers[dt_replace]:=@BotCallbackReplace;
  //Bot.OnReceiveMessage:=@BotReceiveMessage;
  //Bot.OnReceiveInlineQuery:=@BotReceiveInlineQuery;

  //Bot.OnAfterParseUpdate:=@BotAfterParseUpdate;
  //Bot.OnReceiveDeepLinking:=@BotReceiveDeepLink;
  //Bot.Logger:=Logger;
end;

destructor TSchoolBotPlugin.Destroy;
begin
  FCoursesDB.Free;
  inherited Destroy;
end;

procedure TSchoolBotPlugin.Post;
begin
  inherited Post;
end;

end.

