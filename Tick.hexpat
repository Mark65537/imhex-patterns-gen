import gen;

struct PlayerData {
    // Сила ударов (GG: GD8B-WAH0 / GD8V-WABJ / GD8B-WAET)
    u16 Player_punch_force          @ 0x19FCF6;
    u16 Player_kick_force           @ 0x19FD28;
    u16 Player_jumpKick_force       @ 0x19FC90;

    u16 Player_special           @ 0x176B86;
    u16 Player_Lives        @ 0x1A593C;
    u16 Player_HP_after_first_live        @ 0x17572A;
    u16 Player_HP_first_live        @ 0x17517A;

    COLOR Player_Palette[16] @ 0x1FD2E;
};

struct EnemyData {
    u16 Red_ninja_energy @ 0x19F1CE;
};

struct Text {
    char Menu_text[81] @ 0x1A58BB;
    char Subplots_text[91] @ 0x1A5837;
    char Cheat_stages_text[40] @ 0x1A554C;
    char Cheat_substages_text[680] @ 0x1A5580;
};

EnemyData enemy @ 0x0;
PlayerData player @ 0x0;
Text text @ 0x0;