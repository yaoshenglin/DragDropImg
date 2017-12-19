//
//  EnumTypes.h
//  iFace
//
//  Created by APPLE on 14-9-9.
//  Copyright © 2014年 weicontrol. All rights reserved.
//

#ifndef iFace_EnumTypes_h
#define iFace_EnumTypes_h

#define DeviceRate (int)100000

#pragma mark 客户端类型(Enum_iPhoneType)
typedef NS_ENUM(int, Enum_iPhoneType) {
    Device_All      = 0,    //All
    Device_Browser  = 1,    //Browser
    Device_PC       = 2,    //PC
    Device_Android  = 3,    //Android
    Device_iOS      = 4,    //iOS
    Device_WP       = 5,    //WP
};

#pragma mark 客户端类型(Enum_AgentType)
typedef NS_ENUM(int, Enum_AgentType) {
    Agent_All       = 0,    //All
    Agent_iPhone    = 1,    //APP客户端
    Agent_Indoor    = 2,    //室内机
    Agent_Access    = 3,    //门禁机
};

#pragma mark 登录类型(Enum_LoginType)
typedef NS_ENUM(int, Enum_LoginType) {
    Login_QQ         = 1,    //QQ
    Login_WX         = 2,    //WX微信
    Login_iFace      = 3,    //iFace登录
    Login_Facebook   = 4,    //facebook登录
    Login_Twitter    = 5,    //twitter登录
};

#pragma mark 手机验证码类型类型(Enum_MobileCodeType)
typedef NS_ENUM(int, Enum_MobileCodeType) {
    MobileCode_Bingding  = 1,    //绑定手机短信验证码
    MobileCode_Update    = 2,    //更换手机短信验证码
    MobileCode_Register  = 3,    //注册
    MobileCode_ResetPwd  = 4     //重置密码
};

#pragma mark 当前工作模式(Enum_WorkingMode)
typedef NS_ENUM(int, Enum_WorkingMode) {
    WorkingMode_None        = 0,            //无
    WorkingMode_Online      = 1,            //远程模式（在线模式）
    WorkingMode_Offline     = 2             //离线模式（局域网模式）
};

typedef NS_ENUM(int, Enum_TempType) {
    TempType_C = 1,
    TempType_F = 2
};

#pragma mark 通知类型(Enum_NoticeType)
typedef NS_ENUM(int, Enum_NoticeType) {
    Notice_AddFamily        = 1,            //添加家庭成员
    Notice_RemoveFamily     = 2,            //移除家庭成员
    Notice_UPAdmin          = 3,            //变更管理员(已经取消使用了)
    Notice_OpenTask         = 4,            //开启智能任务OR定时任务
    Notice_Reset            = 5,            //主机复位
    Notice_BecomeAdmin      = 6,            //变为管理员
    Notice_AddAdmin         = 7             //通知管理员用户加入家庭组
};

#pragma mark 密码操作模式(Enum_PWDType)
typedef NS_ENUM(int, Enum_PWDType) {
    PWDType_Add     = 1,            //添加密码
    PWDType_Alter   = 2,            //修改密码
    PWDType_Check   = 3,            //验证密码
    PWDType_Delete  = 4             //删除密码
};

#pragma mark 发送数据类型Tag(Enum_SendTag)
typedef NS_ENUM(long, Enum_SendTag) {
    SendTag_Default         =  0,           //发送默认绑定
    SendTag_Heart           =  1,           //发送绑定心跳包
    SendTag_ReadControl     =  2,           //发送绑定读取主机
    SendTag_ReadSlave       =  3,           //发送绑定读取从机
    SendTag_OpenSlave       =  4,           //发送绑定开启从机
    SendTag_CloseSlave      =  5,           //发送绑定关闭从机
    SendTag_UploadConfig    =  6,           //发送上传主机配置信息
    SendTag_InfraredStudy   =  7,           //发送添加红外学习下发指令
    SendTag_InfraredAction  =  8,           //发送红外指令
    SendTag_ReadDoor        =  9,           //读取门禁状态
    SendTag_OpenDoor        = 10,           //发送开门指令
    SendTag_ConnectDoor     = 11,           //发送连接门指令
    SendTag_ReadTemp        = 12,           //读取主机温度
    SendTag_SmartMatch      = 13,           //发送智能匹配下发指令
    SendTag_ReadLockStatus  = 14,           //读取门锁状态指令
    SendTag_OpenLock        = 15,           //发送开启门锁指令
    SendTag_GetLEDStatus    = 16,           //获取LED未配置状态
    
    //LED
    SendTag_AddLEDHost         = 17,           //添加主机
    SendTag_RemoveLEDHost      = 18,           //删除ID号主机
    SendTag_ReadLEDHostID      = 19,           //读取ID号主机
    SendTag_GetLEDNotSet       = 20,           //获取未配置的LED灯信息
    SendTag_GetLEDHadSet       = 21,           //获取 当前已配置的LED的MAC
    SendTag_ControlLEDHost     = 22,           //设置（控制）ID号主机，id号从机的设备状
    SendTag_GetLEDs            = 23,            //批量获取设备状态
    SendTag_GetLEDNewDevices   = 24,            //获取新设备
    SendTag_LEDGroupControl_01    = 25,            //群控（点击立即执行按钮）
    SendTag_LEDGroupControl_02    = 26,            //群控（直接点击switch开关）
    
    
    LEDOperationType_ChangeColor         = 59,           //改变颜色
    LEDOperationType_Power               = 60,           //电源
    LEDOperationType_NaturalColor        = 61,           //自然色
    LEDOperationType_WarmColor           = 62,           //暖色
    LEDOperationType_ColdColor           = 63,           //冷色
    LEDOperationType_DarkLight           = 64,           //夜光灯
    LEDOperationType_ColorTemperature    = 65,           //色温
    LEDOperationType_Lightness           = 66,           //光度
    LEDOperationType_Speed               = 67,           //速度
    LEDOperationType_Gradient            = 68,           //渐变
    LEDOperationType_Scense              = 69,           //场景
};

#pragma mark 发送超时时间(主机)(Enum_ReceiveTimeOut)
typedef NS_ENUM(int, Enum_ReceiveTimeOut) {
    
    TimeOut_Never       = -1,       //默认不设置超时
    TimeOut_Online      = 5,        //远程模式超时（单位：秒）
    TimeOut_Offline     = 2         //离线模式超时（单位：秒）
};

#pragma mark 从机设备状态(Enum_SlaveStatus)
typedef NS_ENUM(int, Enum_SlaveStatus) {
    SlaveStatus_None    = 0,            //未知状态
    SlaveStatus_Open    = 1,            //开启
    SlaveStatus_Close   = 2             //关闭
};

#pragma mark 主机从属类型(Enum_HostSubType)
typedef NS_ENUM(int, Enum_HostSubType) {
    HostSubType_None        = 0,        //未知状态
    HostSubType_Retain      = 1,        //开启
    HostSubType_CloudHome   = 2,        //关闭
    HostSubType_SDK         = 3,        //关闭
    HostSubType_Lesoon      = 4,        //关闭
    HostSubType_LED         = 5         //关闭
};

#pragma mark 从机设备类型(Enum_SlaveType)
typedef NS_ENUM(int, Enum_SlaveType) {
    SlaveType_None          = 0,        //未知设备
    Switch_Switch           = 1,        //开关
    Switch_Outlet           = 2,        //插座
    Switch_Lamp             = 3,        //灯
    Switch_ElectricFan      = 4,        //电风扇
    Switch_WaterDispenser   = 5,        //饮水机
    Switch_Sound            = 6,        //音响
    Switch_RiceCooker       = 7,        //电饭锅
    Switch_FogGlass         = 8,        //雾化窗玻
    IrDA_Transponder        = 9,        //红外转发器
    Switch_Curtain          = 10,       //窗帘
    RemoteVideo             = 11,       //远程视频
                                        //尿不湿
    LED_Lamp                = 13,       //LED灯
    LED_GroupsCtrl          = 14,       //LED灯控制器
    
    
    //红外设备类型（红外的二级枚举类型 移位 11~）
    IrDA_None               = 100,      //未知设备
    IrDA_TV                 = 101,      //电视机
    IrDA_AC                 = 102,      //空调
    IrDA_STB                = 103,      //机顶盒
    IrDA_Fan                = 104,      //风扇
    IrDA_DVD                = 105,      //DVD
    IrDA_ACL                = 106,      //空气净化器
    
    IrDA_IPTV               = 150,      //IPTV
    IrDA_MiBox              = 151,      //小米盒子
    IrDA_LeTV               = 152,      //乐视盒子
    
    Switch_DoorLock         = 200,      //木门锁(普通)
    Switch_GateLock         = 201,      //铁门锁(蓝牙密码，没有指纹)
    Switch_BTFPLock         = 202,      //蓝牙指纹门锁(不带卡)
    Switch_BTNPLock         = 203,      //蓝牙指纹门锁(带卡)
    
    SlaveType_DoorControl   = 300,      //门禁
    
    IrDACus_AC              = 1007,     //自定义学习空调
    IrDACus_TV              = 1008,     //自定义学习电视
    IrDACus_STB             = 1009,     //自定义学习机顶盒
    IrDACus_Fan             = 1010,     //自定义学习风扇
    IrDACus_DVD             = 1011,     //自定义学习DVD
    IrDACus_ACL             = 1012,     //自定义学习空气净化器
    IrDACus_IPTV            = 1013,     //自定义学习网络电视
};

#pragma mark 设备类型(Enum_DeviceType)
typedef NS_ENUM(int, Enum_DeviceType) {
    DeviceType_None               = 0,        //未知
    DeviceType_Switch             = 1<< 0,    //开关
    DeviceType_Outlet             = 1<< 1,    //插座
    DeviceType_IrDA               = 1<< 2,    //红外
    DeviceType_Gate               = 1<< 3,    //门禁
    DeviceType_Lock               = 1<< 4,    //门锁
    DeviceType_Park               = 1<< 5,    //车位锁
    DeviceType_FogGlass           = 1<< 6,    //雾化窗玻
    DeviceType_IrTs               = 1<< 7,    //红外转发器
    DeviceType_Curtain            = 1<< 8,    //窗帘
    DeviceType_Webcam             = 1<< 9,    //网络摄像头
    DeviceType_LED                = 1<< 10,   //LED灯
    DeviceType_LEDGroupsCtrl      = 1<< 11,   //LED灯控制器
};

#pragma mark 从机固件升级类型(Enum_DeviceDataType)
typedef NS_ENUM(int, Enum_DeviceDataType)
{
    DataType_None       = 0,      //未知
    DataType_Switch     = 1,      //开关
    DataType_Outlet     = 2,      //插座
    DataType_Lock       = 3,      //门锁
    DataType_Park       = 4,      //车位锁
    DataType_FogGlass   = 5,      //雾化窗玻
    DataType_IrTs       = 6,      //红外转发器
    DataType_Curtain    = 7,      //电动窗帘
};

#pragma mark 自定义设备类型(Enum_CustomDeviceType)
typedef NS_ENUM(int, Enum_CustomDeviceType) {
    CustomDevice_None   = 0,    //未知
    CustomDevice_AC     = 1,    //空调
    CustomDevice_TV     = 2,    //电视
    CustomDevice_STB    = 3,    //机顶盒
    CustomDevice_FAN    = 4,    //风扇
    CustomDevice_DVD    = 5,    //DVD
    CustomDevice_ACL    = 6,    //空气净化器
};

#pragma mark 数据返回类型(Enum_DataResult)
typedef NS_ENUM(int, Enum_DataResult)
{
    DataResult_None             =  0,            //未知状态
    DataResult_ReadControlID    =  1,            //读取主机ID返回
    DataResult_OpenSlave        =  2,            //开启从机返回
    DataResult_CloseSlave       =  3,            //关闭从机返回
    DataResult_ReadSwitch       =  4,            //读取开关状态返回
    DataResult_IntoStudy        =  6,            //下发学习指令返回
    DataResult_ReceiveCode      =  7,            //接收到遥控编码返回
    DataResult_UploadConfig     =  8,            //上传配置成功返回
    DataResult_ControlHeart     =  9,            //主机心跳包返回
    DataResult_InfraredAction1  = 10,            //执行红外指令返回(来自码库)
    DataResult_InfraredAction2  = 11,            //执行红外指令返回(来自学习)
    DataResult_ReadTemp         = 12,            //读取主机温度返回
    DataResult_SmartMatch       = 13,            //下发智能匹配指令返回
    DataResult_ReceiveMatch     = 14,            //接收到智能匹配数据返回
    DataResult_ReadLockStatus   = 15,            //读取门锁状态
    DataResult_OpenLockOK       = 16,            //接收到开锁成功
    DataResult_OpenLockFail     = 17,            //接收到开锁失败
    DataResult_ConfigLockFail   = 18,            //执行蓝牙指令失败
    DataResult_ReadLED          = 19,            //读取LED返回
    DataResult_SetLockTempPW    = 20             //设置临时密码
};

#pragma mark - LED灯状态返回类型 (Enum_LEDReturnType)
typedef NS_ENUM(int, Enum_LEDReturnType)
{
    LEDReturnType_AddHost           = 242,        //添加主机
    LEDReturnType_RemoveHost        = 243,        //删除ID号主机
    LEDReturnType_ReadHostID        = 244,        //读取ID号主机
    LEDReturnType_GetLEDNotSet      = 245,        //获取未配置的LED灯信息
    LEDReturnType_GetLEDHadSet      = 246,        //获取 当前已配置的LED的MAC
    LEDReturnType_ControlHost       = 247,        //设置（控制）ID号主机，id号从机的设备状态
    LEDReturnType_GetLEDs           = 248,        //批量获取设备状态
    
    LEDReturnType_GroupCOntrol      = 250,        //群控
};

#pragma mark - LED灯的类型
typedef NS_ENUM(NSInteger, Enum_LEDType)
{
    //类型 : 灯带 ， 灯管 ， 平板灯  ， 灯泡灯 ， 筒灯  ， 吸顶
    LEDType_Bulb            =   1,          //灯泡灯
    LEDType_DownLight       =   2,          //筒灯
    LEDType_Ceiling         =   3,          //吸顶
    LEDType_Lamp            =   4,          //灯管
    LEDType_LightBelt       =   5,          //灯带
    LEDType_FlatLamp        =   6,          //平板灯
};

#pragma mark 下载红外类型(Enum_DownloadType)
typedef NS_ENUM(int, Enum_DownloadType)
{
    DownloadType_AC         = 1,           //空调
    DownloadType_TV         = 2,           //电视
    DownloadType_STB        = 3,           //机顶盒
    DownloadType_DVD        = 4,           //DVD/VCD
    DownloadType_FAN        = 5,           //电风扇
    DownloadType_ACL        = 6,           //空气净化器
    DownloadType_IPTV       = 7            //IPTV
};

#pragma mark 数据标识(Enum_DataMark)
// 数据标识 (1、添加2、更新 3、删除)
typedef NS_ENUM(int, Enum_DataMark)
{
    DataMark_None       = 0,           //无操作(表示已经提交过的状态)
    DataMark_Add        = 1,           //添加
    DataMark_Update     = 2,           //更新
    DataMark_Delete     = 3            //删除
};

#pragma mark 红外操作类型(enum_OperationType)
typedef NS_ENUM(int, enum_OperationType) {
    OperationType_Add       = 0,    //添加
    OperationType_Using     = 1,    //使用
    OperationType_Update    = 2,    //更新
    OperationType_Order     = 3,    //获取操作命令
};

#pragma mark 指纹锁开锁认证类型(Enum_Fingerpring_LockType)
typedef NS_OPTIONS(int, Enum_OpenLockType) {
    OpenLockType_Alarm          = 0,      // 0  非法操作
    OpenLockType_App            = 1,      // 1  App
    OpenLockType_Fingerprint    = 1 << 1, // 2  指纹
    OpenLockType_Card           = 1 << 2, // 4  刷卡
    OpenLockType_Password       = 1 << 3, // 8  密码
    OpenLockType_Face           = 1 << 4, // 16 面部
    OpenLockType_Key            = 1 << 5, // 32 钥匙
};

#pragma mark 访客密码组类型(Enum_TempPassword_GroupType)
typedef NS_ENUM(int, Enum_TempPassword_GroupType) {
    Password_Group1              = 1 << 0,//密码组1
    Password_Group2              = 1 << 1,//密码组2
    Password_Group3              = 1 << 2,//密码组3
    Password_Group4              = 1 << 3,//密码组4
    Password_Group5              = 1 << 4,//密码组5
    Password_Group6              = 1 << 5,//密码组6
    Password_Group7              = 1 << 6,//密码组7
    Password_Group8              = 1 << 7,//密码组8
};

#pragma mark 指纹锁开锁认证类型(Enum_Fingerpring_LockType)
typedef NS_ENUM(int, Enum_Fingerpring_LockType) {
    LockType_None                       = 0,//无
    LockType_Default_Or                 = 1,//指纹或卡或密码（任意一种都可以开锁）
    LockType_ALL_And                    = 2,//指纹+卡+密码（所有验证通过才能开锁）
    LockType_FingerOrCardPassword       = 3,//指纹或卡+密码
    LockType_FingerCardOrPassword       = 4,//指纹+卡或密码
    LockType_FingerPasswordOrCard       = 5,//指纹+密码或卡
    LockType_Only_Finger                = 6,//仅指纹
    LockType_Only_Card                  = 7,//仅刷卡
    LockType_Only_Password              = 8 //仅密码
};

#pragma mark 星期(Week)
typedef NS_OPTIONS(NSInteger, Week) {
    Week_None       = 0,      // 0
    Week_Sunday     = 1,      // 1  1 1
    Week_Monday     = 1 << 1, // 2  2 10 转换成 10进制 2
    Week_Tuesday    = 1 << 2, // 4  3 100 转换成 10进制 4
    Week_Wednesday  = 1 << 3, // 8  4 1000 转换成 10进制 8
    Week_Thursday   = 1 << 4, // 16 5 10000 转换成 10进制 16
    Week_Friday     = 1 << 5, // 32 6 100000 转换成 10进制 32
    Week_Saturday   = 1 << 6, // 64 7 1000000 转换成 10进制 64
    Week_All        = Week_Monday | Week_Tuesday | Week_Wednesday| Week_Thursday| Week_Friday| Week_Saturday| Week_Sunday, // 127
};

#pragma mark 门禁状态（Enum_DoorStatus）
typedef NS_ENUM(int,Enum_DoorStatus)
{
    Door_Failed     = -1,    //连接失败或未连接
    Door_Loading    =  0,    //正在连接
    Door_OK         =  1,    //已连接(Door_Close)
    Door_Close      =  1,    //门处于关闭状态
    Door_Opening    =  2,    //门已开(还未推开)
    Door_Opened     =  3,    //门已开(已经推开)
};


#pragma mark 分享类型（Enum_ShareType）
typedef enum
{
    ShareTypeSinaWeibo = 1,         /**< 新浪微博 */
    ShareTypeTencentWeibo = 2,      /**< 腾讯微博 */
    ShareTypeSohuWeibo = 3,         /**< 搜狐微博 */
    ShareType163Weibo = 4,          /**< 网易微博 */
    ShareTypeDouBan = 5,            /**< 豆瓣社区 */
    ShareTypeQQSpace = 6,           /**< QQ空间 */
    ShareTypeRenren = 7,            /**< 人人网 */
    ShareTypeKaixin = 8,            /**< 开心网 */
    ShareTypePengyou = 9,           /**< 朋友网 */
    ShareTypeFacebook = 10,         /**< Facebook */
    ShareTypeTwitter = 11,          /**< Twitter */
    ShareTypeEvernote = 12,         /**< 印象笔记 */
    ShareTypeFoursquare = 13,       /**< Foursquare */
    ShareTypeGooglePlus = 14,       /**< Google＋ */
    ShareTypeInstagram = 15,        /**< Instagram */
    ShareTypeLinkedIn = 16,         /**< LinkedIn */
    ShareTypeTumblr = 17,           /**< Tumbir */
    ShareTypeMail = 18,             /**< 邮件分享 */
    ShareTypeSMS = 19,              /**< 短信分享 */
    ShareTypeAirPrint = 20,         /**< 打印 */
    ShareTypeCopy = 21,             /**< 拷贝 */
    ShareTypeWeixiSession = 22,     /**< 微信好友 */
    ShareTypeWeixiTimeline = 23,    /**< 微信朋友圈 */
    ShareTypeQQ = 24,               /**< QQ */
    ShareTypeInstapaper = 25,       /**< Instapaper */
    ShareTypePocket = 26,           /**< Pocket */
    ShareTypeYouDaoNote = 27,       /**< 有道云笔记 */
    ShareTypeSohuKan = 28,          /**< 搜狐随身看 */
    ShareTypePinterest = 30,        /**< Pinterest */
    ShareTypeFlickr = 34,           /**< Flickr */
    ShareTypeDropbox = 35,          /**< Dropbox */
    ShareTypeVKontakte = 36,        /**< VKontakte */
    ShareTypeWeixiFav = 37,         /**< 微信收藏 */
    ShareTypeYiXinSession = 38,     /**< 易信好友 */
    ShareTypeYiXinTimeline = 39,    /**< 易信朋友圈 */
    ShareTypeYiXinFav = 40,         /**< 易信收藏 */
    ShareTypeMingDao = 41,          /**< 明道 */
    ShareTypeLine = 42,             /**< Line */
    ShareTypeWhatsApp = 43,         /**< Whats App */
    ShareTypeKaKaoTalk = 44,        /**< KaKao Talk */
    ShareTypeKaKaoStory = 45,       /**< KaKao Story */
    ShareTypeOther = -1,            /**< > */
    ShareTypeAny = 99               /**< 任意平台 */
}
ShareType;

#pragma MARK 门锁错误类型:
/*
 0.同步到网关成功
 1.同步到锁成功
 2.安全码错误
 3.APP开锁功能已被禁用（硬件APP开锁功能已被禁用，APP及钥匙分享功能将不能使用）
 4.通信异常（请检查主机与设备距离是否过远，设备是否激活上电）
 5.门锁未唤醒（请唤醒门锁后操作
 */
typedef enum : NSUInteger {
    LockErrorType_SuccessUpdateToNet              =0 ,    //同步到网关成功
    LockErrorType_SuccessUpdateToLock,                    //同步到锁成功
    LockErrorType_SafeCodeError,                          //安全码错误
    LockErrorType_ForbitOpenLock,                         //APP开锁功能已被禁用
    LockErrorType_NetworkFail,                            //通信异常（请检查主机与设备距离是否过远，设备是否激活上电）
    LockErrorType_LockSleep,                              //门锁未唤醒（请唤醒门锁后操作
} LockErrorType;

#endif
