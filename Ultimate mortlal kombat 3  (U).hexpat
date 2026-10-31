#pragma author Marksiks
#pragma description Sega Genesis/MegaDrive Ultimate mortal kombat 3 U
#pragma source 

#pragma endian big

import std.string;

//HEADER

struct M68000Vectors {
    u32 stackPointerReset;
    u32 programCounterReset [[comment("Entry Point")]];
    u32 busError;
    u32 addressError;
    u32 illegalInstruction;
    u32 divisionByZero;
    u32 chkInstruction;
    u32 trapVInstruction;
    u32 privilegeViolation;
    u32 trace;
    u32 lineAInstruction;
    u32 lineFInstruction;
    padding[12];
    u32 uninitializedInterruptVector;
    padding[32];
    u32 spuriousInterrupt;
    u32 interruptAutovectors[7];
    u32 traps[16];
};

M68000Vectors vectors @ 0x00;

struct Info {
    char softwareType[2];
    char space;
    char serialNumber[8];
    char dash;
    char revision[2];
};

enum DeviceType : char {
    NotFilled = ' ',
    Button3Controller = 'J',
    Button6Controller = '6',
    MasterSystemController = '0',
    AnalogJoystick = 'A',
    Multitap = '4',
    Lightgun = 'G',
    Activator = 'L',
    Mouse = 'M',
    Trackball = 'B',
    Mouse = 'T',
    Trackball = 'V',
    Keyboard = 'K',
    RS232 = 'R',
    Printer = 'P',
    CDROM = 'C',
    FloppyDrive = 'F',
    Download = 'D'
};

bitfield RAMType {
    addresses : 1;
    padding : 3;
    bits : 2;
    saves : 1;
    sig : 1;
};

enum MemoryType : char {
    RAM = ' ',
    EEPROM = '@'
};

struct ExtraMemory {
    char signature[2];
    RAMType ramType;
    MemoryType memoryType;
    u32 startAddress;
    u32 endAddress;
};

fn renderMicrophoneType(str value) {
    match(value) {
        ("00"): value = "NoMicJapanOnly";
        ("10"): value = "MicJapanOnly";
        ("20"): value = "NoMicOverseasOnly";
        ("30"): value = "MicOverseasOnly";
        ("40"): value = "NoMic";
        ("50"): value = "Mic";
        ("60"): value = "NoMicJapan";
        ("70"): value = "NoMicOverseas";
    }
};

struct ModemSupport {
    char signature[2];
    char publisher[4];
    char gameNumber[2];
    char comma;
    char version;
    char microphone[2] [[format("renderMicrophoneType")]];
};

enum RegionType : char {
    None = ' ',
    Japan = 'J',
    Americas = 'U',
    Europe = 'E'
};

fn formatTerminatedString(str string) {
    u8 index;
    while (index < std::string::length(string)) {
        if (std::mem::read_string($+index, 2) == "  ")
            break;
        index += 1;
    }
    return "\"" + std::string::substr(string, 0, index) + "\"";
};

struct Header {
    char systemType[16] [[format("formatTerminatedString")]];
    char copyright[16] [[format("formatTerminatedString")]];
    char domesticTitle[48] [[format("formatTerminatedString")]];
    char overseasTitle[48] [[format("formatTerminatedString")]];
    Info info;
    u16 checksum;
    DeviceType deviceType[16];
    u32 romAddressRange[2];
    u32 ramAddressRange[2];
    if ($[$] == 'R') ExtraMemory extraMemory; else padding[12];
    if ($[$] == 'M') ModemSupport modemSupport; else padding[12];
    padding[40];
    RegionType regions[3];
};

Header header @ 0x100;

//CONSTANTS
u8 PLAYABLE_PLAYER_COUNT = 24; //0x18
u8 ALL_PLAYER_COUNT = 27; //0x1B

//Sequence of characters in Player Select

enum CHARS : u16 {
    Kano = 0x00,
    Sonya = 0x01,
    Jax = 0x02,
    Nightwolf = 0x03,
    UnmaskedSubZ = 0x04,
    Stryker = 0x05,
    Sindel = 0x06,
    Sektor = 0x07,
    Cyrax = 0x08,
    KungLao = 0x09,
    Kabal = 0x0a,
    ShangTsung = 0x0c,
    LiuKang = 0x0d,
    Smoke = 0x0e,
    Kitana = 0x0f,
    Jade = 0x10,
    Mileena = 0x11,
    Scorpion = 0x12,
    Reptile = 0x13,
    Ermac = 0x14,
    ClassicSubZ = 0x15,
    HumanSmoke = 0x16,
    NoobSaibot = 0x17,
    Rain = 0x18,
    Chameleon = 0x19,
    Motaro = 0x1A,
    ShaoKahn = 0x1B,
    Exception = 0x1C
};

struct PlayerSequence {
    CHARS sequence[24];
};

u32 rosterRef @ 0xDD4C;
PlayerSequence playerSequence @ 0xDFC8;

u32 RosterIndexesRef @ 0xDFF8;

u8 RosterIndexes[25] @ RosterIndexesRef;

//Graphic archive

struct ArchiveHeader {
    u16 Type;
};


//Portraits

struct PortraitData {
    //u8 TileSet[894];
    u32 ref_TileSet;
    padding[4];
    u32 ref_TileMap;
    padding[32];
    u32 ref_to_TileMap_again; // it's usefull if you change orig
    u32 TileSet_Size [[comment("TileSet Size")]];
    padding[8];
    //u8 TileMap[72]; // not constant number
};


//ref to portrait ref
enum PORTRAIT_HEADER_POINTER : u32 {
    Rain = 0x00DE9C,
    Reptile = 0xDEA4,
    Stryker = 0xDEAC,
    Jax = 0xDEB4,
    Nightwolf = 0xDEBC,
    Jade = 0xDEC4,
    NoobSaibot = 0xDECC,
    Sonya = 0xDED4,
    Kano = 0xDF44,
    Mileena = 0xDEDC,
    SecretChar = 0xDF54, 
    UnmaskedSubZ = 0xDEE4,
    ClassicSubZ = 0xDEEC,
    KungLao = 0xDEF4,
    Sector = 0xDEFC,
    Kitana = 0xDF04,
    Ermac = 0xDF0C,
    Scorpion = 0xDF4C,
    Cyrax = 0xDF14,
    Kabal = 0xDF1C,
    Sindel = 0xDF24,
    Smoke = 0xDF2C,
    LiuKang = 0xDF3C,
    ShangTsung = 0xDF34
    //Motaro = 0x1A,
    //ShaoKahn = 0x1B
};

enum PORTRAIT_HEADER_REF : u32 {
    Rain = 0x000AA732,
    Reptile = 0x000AAB56,
    Stryker = 0x000AAF78,
    Jax = 0x000AB390,
    Nightwolf = 0x000AB82E,
    Jade = 0x000ABCC0,
    NoobSaibot = 0x000ABFA0,
    Sonya = 0x000AC4AC,
    Kano = 0x000AC94E,
    Mileena = 0x000ACDB4,
    SecretChar = 0x000B19B8, 
    UnmaskedSubZ = 0x000AD6D4,
    ClassicSubZ = 0x000ADBB0,
    KungLao = 0x000ADFD4,
    Sector = 0x000AE474,
    Kitana = 0x000AE93C,
    Ermac = 0x000AD182,
    Scorpion = 0x000AED54,
    Cyrax = 0x000AF1FA,
    Kabal = 0x000AF654,
    Sindel = 0x000AFB1E,
    Smoke = 0x000B0080,
    LiuKang = 0x000B0538,
    ShangTsung = 0x000B0922
    //Motaro = 0x1A,
    //ShaoKahn = 0x1B
};

PORTRAIT_HEADER_REF RainPortraitRef @ PORTRAIT_HEADER_POINTER::Rain;
PORTRAIT_HEADER_REF ReptilePortraitRef @ PORTRAIT_HEADER_POINTER::Reptile;
PORTRAIT_HEADER_REF StrykerPortraitRef @ PORTRAIT_HEADER_POINTER::Stryker;
PORTRAIT_HEADER_REF JaxPortraitRef @ PORTRAIT_HEADER_POINTER::Jax;
PORTRAIT_HEADER_REF NightWolfPortraitRef @ PORTRAIT_HEADER_POINTER::Nightwolf;
PORTRAIT_HEADER_REF JadePortraitRef @ PORTRAIT_HEADER_POINTER::Jade;
PORTRAIT_HEADER_REF NoobSaibotPortraitRef @ PORTRAIT_HEADER_POINTER::NoobSaibot;
PORTRAIT_HEADER_REF SonyaPortraitRef @ PORTRAIT_HEADER_POINTER::Sonya;
PORTRAIT_HEADER_REF KanoPortraitRef @ PORTRAIT_HEADER_POINTER::Kano;
PORTRAIT_HEADER_REF MileenaPortraitRef @ PORTRAIT_HEADER_POINTER::Mileena;
PORTRAIT_HEADER_REF SecretCharPortraitRef @ PORTRAIT_HEADER_POINTER::SecretChar;
PORTRAIT_HEADER_REF UnmaskedSubZPortraitRef @ PORTRAIT_HEADER_POINTER::UnmaskedSubZ;
PORTRAIT_HEADER_REF ClassicSubzPortraitRef @ PORTRAIT_HEADER_POINTER::ClassicSubZ;
PORTRAIT_HEADER_REF KungLaoPortraitRef @ PORTRAIT_HEADER_POINTER::KungLao;
PORTRAIT_HEADER_REF SectorPortraitRef @ PORTRAIT_HEADER_POINTER::Sector;
PORTRAIT_HEADER_REF KitanaPortraitRef @ PORTRAIT_HEADER_POINTER::Kitana;
PORTRAIT_HEADER_REF ErmacPortraitRef @ PORTRAIT_HEADER_POINTER::Ermac;
PORTRAIT_HEADER_REF ScorpionPortraitRef @ PORTRAIT_HEADER_POINTER::Scorpion;
PORTRAIT_HEADER_REF CyraxPortraitRef @ PORTRAIT_HEADER_POINTER::Cyrax;
PORTRAIT_HEADER_REF KabalPortraitRef @ PORTRAIT_HEADER_POINTER::Kabal;
PORTRAIT_HEADER_REF SindelPortraitRef @ PORTRAIT_HEADER_POINTER::Sindel;
PORTRAIT_HEADER_REF SmokePortraitRef @ PORTRAIT_HEADER_POINTER::Smoke;
PORTRAIT_HEADER_REF LiuKangPortraitRef @ PORTRAIT_HEADER_POINTER::LiuKang;
PORTRAIT_HEADER_REF ShangTsungPortraitRef @ PORTRAIT_HEADER_POINTER::ShangTsung;

PortraitData rainPortrait @ PORTRAIT_HEADER_REF::Rain;
PortraitData reptilePortrait @ PORTRAIT_HEADER_REF::Reptile;
PortraitData strykerPortrait @ PORTRAIT_HEADER_REF::Stryker;
PortraitData jaxPortrait @ PORTRAIT_HEADER_REF::Jax;
PortraitData nightwolfPortrait @ PORTRAIT_HEADER_REF::Nightwolf;
PortraitData jadePortrait @ PORTRAIT_HEADER_REF::Jade;
PortraitData noobSaibotPortrait @ PORTRAIT_HEADER_REF::NoobSaibot;
PortraitData sonyaPortrait @ PORTRAIT_HEADER_REF::Sonya;
PortraitData kanoPortrait @ PORTRAIT_HEADER_REF::Kano;
PortraitData MileenaPortrait @ PORTRAIT_HEADER_REF::Mileena;
PortraitData secretCharPortrait @ PORTRAIT_HEADER_REF::SecretChar;
PortraitData unmaskedSubZPortrait @ PORTRAIT_HEADER_REF::UnmaskedSubZ;
PortraitData classicSubZPortrait @ PORTRAIT_HEADER_REF::ClassicSubZ;
PortraitData kungLaoPortrait @ PORTRAIT_HEADER_REF::KungLao;
PortraitData sectorPortrait @ PORTRAIT_HEADER_REF::Sector;
PortraitData kitanaPortrait @ PORTRAIT_HEADER_REF::Kitana;
PortraitData ermacPortrait @ PORTRAIT_HEADER_REF::Ermac;
PortraitData scorpionPortrait @ PORTRAIT_HEADER_REF::Scorpion;
PortraitData cyraxPortrait @ PORTRAIT_HEADER_REF::Cyrax;
PortraitData kabalPortrait @ PORTRAIT_HEADER_REF::Kabal;
PortraitData sindelPortrait @ PORTRAIT_HEADER_REF::Sindel;
PortraitData smokePortrait @ PORTRAIT_HEADER_REF::Smoke;
PortraitData liuKangPortrait @ PORTRAIT_HEADER_REF::LiuKang;
PortraitData shangTsungPortrait @ PORTRAIT_HEADER_REF::ShangTsung;