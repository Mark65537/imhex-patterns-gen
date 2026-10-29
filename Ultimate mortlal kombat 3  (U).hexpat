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

PlayerSequence playerSequence @ 0xDFC8;

//Graphic archive

struct ArchiveHeader {
    u16 Type
};


//Portraits

struct PortraitData {
    //u8 TileSet[894];
    u32 ref_TileSet;
    padding[4];
    u32 ref_TileMap;
    padding[32];
    u32 ref_to_TileMap_again;
    u32 TileSet_Size [[comment("TileSet Size")]];
    padding[8];
    u8 TileMap[72]; // not constant number
};

PortraitData rainPortrait @ 0xAA732;//0xAA3B4;
PortraitData sonyaPortrait @ 0xAC4AC;//0xAC054;