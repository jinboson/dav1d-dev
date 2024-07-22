/*
 * Copyright © 2023, VideoLAN and dav1d authors
 * Copyright © 2023, Loongson Technology Corporation Limited
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "src/loongarch/loongson_asm.S"

/*
static void splat_mv_c(refmvs_block **rr, const refmvs_block *const rmv,
                       const int bx4, const int bw4, int bh4)
*/

function splat_mv_lsx
    vld           vr0,      a1,       0          // 0 1 ... 11 ...
    clz.w         t4,       a3
    vaddi.bu      vr1,      vr0,      0
    addi.w        t4,       t4,       -26
    vextrins.w    vr1,      vr0,      0x30       // 0 1 2 ... 11 0 1 2 3
    la.local      t5,       .SPLAT_LSX_JRTABLE
    vbsrl.v       vr2,      vr1,      4          // 4 5 6 7...11 0 1 2 3 0 0 0 0
    alsl.d        t6,       t4,       t5,     1
    vextrins.w    vr2,      vr0,      0x31       // 4 5 6 7...11 0 1 2 3 4 5 6 7
    ld.h          t7,       t6,       0
    vbsrl.v       vr3,      vr2,      4          // 8 9 10 11 0 1 2 3 4 5 6 7 0 0 0 0
    add.d         t8,       t5,       t7
    alsl.d        a2,       a2,       a2,     1
    vextrins.w    vr3,      vr0,      0x32       // 8 9 10 11 0 1 2 3 4 5 6 7 8 9 10 11
    slli.w        a2,       a2,       2
    jirl          $r0,      t8,       0

.SPLAT_LSX_JRTABLE:
    .hword .SPLAT_W32_LSX - .SPLAT_LSX_JRTABLE
    .hword .SPLAT_W16_LSX - .SPLAT_LSX_JRTABLE
    .hword .SPLAT_W8_LSX  - .SPLAT_LSX_JRTABLE
    .hword .SPLAT_W4_LSX  - .SPLAT_LSX_JRTABLE
    .hword .SPLAT_W2_LSX  - .SPLAT_LSX_JRTABLE
    .hword .SPLAT_W1_LSX  - .SPLAT_LSX_JRTABLE

.SPLAT_W1_LSX:
    ld.d          t3,       a0,       0
    addi.d        a0,       a0,       8
    addi.d        a4,       a4,       -1
    add.d         t3,       t3,       a2

    fst.d         f1,       t3,       0
    fst.s         f3,       t3,       8
    blt           zero,     a4,       .SPLAT_W1_LSX
    b             .splat_end
.SPLAT_W2_LSX:
    ld.d          t3,       a0,       0
    addi.d        a0,       a0,       8
    addi.d        a4,       a4,       -1
    add.d         t3,       t3,       a2

    vst           vr1,      t3,       0
    fst.d         f2,       t3,       16
    blt           zero,     a4,       .SPLAT_W2_LSX
    b             .splat_end

.SPLAT_W4_LSX:
    ld.d          t3,       a0,       0
    addi.d        a0,       a0,       8
    addi.d        a4,       a4,       -1
    add.d         t3,       t3,       a2

    vst           vr1,      t3,       0
    vst           vr2,      t3,       16
    vst           vr3,      t3,       32
    blt           zero,     a4,       .SPLAT_W4_LSX
    b             .splat_end

.SPLAT_W8_LSX:
    ld.d          t3,       a0,       0
    addi.d        a0,       a0,       8
    addi.d        a4,       a4,       -1
    add.d         t3,       t3,       a2

    vst           vr1,      t3,       0
    vst           vr2,      t3,       16
    vst           vr3,      t3,       32

    vst           vr1,      t3,       48
    vst           vr2,      t3,       64
    vst           vr3,      t3,       80
    blt           zero,     a4,       .SPLAT_W8_LSX
    b             .splat_end

.SPLAT_W16_LSX:
    ld.d          t3,       a0,       0
    addi.d        a0,       a0,       8
    addi.d        a4,       a4,       -1
    add.d         t3,       t3,       a2

.rept 2
    vst           vr1,      t3,       0
    vst           vr2,      t3,       16
    vst           vr3,      t3,       32

    vst           vr1,      t3,       48
    vst           vr2,      t3,       64
    vst           vr3,      t3,       80

    addi.d        t3,       t3,       96
.endr

    blt           zero,     a4,       .SPLAT_W16_LSX
    b             .splat_end

.SPLAT_W32_LSX:
    ld.d          t3,       a0,       0
    addi.d        a0,       a0,       8
    addi.d        a4,       a4,       -1
    add.d         t3,       t3,       a2

.rept 4
    vst           vr1,      t3,       0
    vst           vr2,      t3,       16
    vst           vr3,      t3,       32

    vst           vr1,      t3,       48
    vst           vr2,      t3,       64
    vst           vr3,      t3,       80

    addi.d        t3,       t3,       96
.endr

    blt           zero,     a4,       .SPLAT_W32_LSX

.splat_end:
endfunc

const mv_tbls
    .byte           255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    .byte           0, 1, 2, 3, 8, 0, 1, 2, 3, 8, 0, 1, 2, 3, 8, 0
    .byte           4, 5, 6, 7, 9, 4, 5, 6, 7, 9, 4, 5, 6, 7, 9, 4
    .byte           4, 5, 6, 7, 9, 4, 5, 6, 7, 9, 4, 5, 6, 7, 9, 4
endconst

const mask_mult
    .byte           1, 0, 2, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0
endconst

const mask_mv0
    .byte           1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
endconst

const mask_mv1
    .byte           4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
endconst


// void dav1d_save_tmvs_neon(refmvs_temporal_block *rp, ptrdiff_t stride,
//                           refmvs_block **rr, const uint8_t *ref_sign,
//                           int col_end8, int row_end8,
//                           int col_start8, int row_start8)
function save_tmvs_lsx
    addi.d      sp,         sp,        -0x28
    st.d        s0,         sp,         0x00
    st.d        s1,         sp,         0x08
    st.d        s2,         sp,         0x10
    st.d        s3,         sp,         0x18
    st.d        s4,         sp,         0x20
    move        t0,         ra

    vxor.v      vr10,       vr10,       vr10
    vld         vr11,       a3,         0       // Load ref_sign[0] ~ Load ref_sign[7]
    la.local    t2,         .save_tevs_tbl
    la.local    s1,         mask_mult
    la.local    t7,         mv_tbls
    vld         vr9,        s1,         0       // Load mask_mult
    vslli.d     vr11,       vr11,       8       // 0, ref_sign[0], ... ,ref_sign[6]
    la.local    s3,         mask_mv0
    vld         vr8,        s3,         0       // Load mask_mv0
    la.local    s4,         mask_mv1
    vld         vr7,        s4,         0       // Load mask_mv1
    li.d        s0,         5
    li.d        t8,         12 * 2
    mul.d       a1,         a1,         s0     // stride *= 5
    sub.d       a5,         a5,         a7      // h = row_end8 - row_start8
    slli.d      a7,         a7,         1       // row_start8 <<= 1
1:
    li.d        s0,         5
    andi        t3,         a7,         30      // (y & 15) * 2
    slli.d      s4,         t3,         3
    ldx.d       t3,         a2,         s4      // b = rr[(y & 15) * 2]
    addi.d      t3,         t3,         12      // &b[... + 1]
    mul.d       s4,         a4,         t8
    add.d       t4,         s4,         t3      // end_cand_b = &b[col_end8*2 + 1]
    mul.d       s3,         a6,         t8
    add.d       t3,         s3,         t3      // cand_b = &b[x*2 + 1]
    mul.d       s4,         a6,         s0
    add.d       a3,         s4,         a0      // &rp[x]
2:
    /* First cand_b */
    ld.b        t5,         t3,         10      // cand_b->bs
    vld         vr0,        t3,         0       // cand_b->mv and ref
    alsl.d      t5,         t5,         t2,     2  // bt2 index
    ld.h        s3,         t3,         8       // cand_b->ref
    ld.h        t6,         t5,         0       // bt2
    move        s0,         t2
    alsl.d      t3,         t6,         t3,     1   // Next cand_b += bt2 * 2
    vor.v       vr2,        vr0,        vr0
    vinsgr2vr.h vr1,        s3,         0
    move        t1 ,        t3
    bge         t3,         t4,        3f

    /* Next cand_b */
    ld.b        s0,         t3,         10      // cand_b->bs
    vld         vr4,        t3,         0       // cand_b->mv and ref
    alsl.d      s0,         s0,         t2,     2 // bt2 index
    ld.h        s4,         t3,         8       // cand_b->ref
    ld.h        t6,         s0,         0       // bt2
    alsl.d      t3,         t6,         t3,     1   // Next cand_b += bt2*2
    vpackev.d   vr2,        vr4,        vr0     // a0.mv[0] a0.mv[1] a1.mv[0], a1.mv[1]
    vinsgr2vr.h vr1,        s4,         1   // a0.ref[0] a0.ref[1], a1.ref[0], a1.ref[1]
3:
    vabsd.h     vr2,        vr2,        vr10    // abs(mv[].xy)
    vshuf.b     vr1,        vr11,       vr11,   vr1     // ref_sign[ref]
    vsrli.h     vr2,        vr2,        12      // abs(mv[].xy) >> 12
    vilvl.b     vr1,        vr1,        vr1
    vmulwev.h.bu    vr1,    vr1,        vr9    // ef_sign[ref] * {1, 2}

    vseqi.w     vr2,        vr2,        0       // abs(mv[].xy) <= 4096
    vpickev.h   vr2,        vr2,        vr2     // abs() condition to 16 bit

    vand.v      vr1,        vr2,        vr1     // h[0-3] contains conditions for mv[0-1]
    vhaddw.wu.hu    vr1,    vr1,        vr1     // Combine condition for [1] and [0]
    vpickve2gr.wu   s1,     vr1,        0       // Extract case for first block
    vpickve2gr.wu   s2,     vr1,        1

    ld.hu           t5,     t5,         2       // Fetch jump table entry
    ld.hu           s0,     s0,         2
    alsl.d          s3,     s1,         t7,    4   // Load permutation table base on case
    vld             vr1,    s3,         0
    alsl.d          s4,     s2,         t7,    4
    vld             vr5,    s4,         0
    sub.d           t5,     t2,         t5     // Find jump table target
    sub.d           s0,     t2,         s0
    vshuf.b         vr0,    vr0,        vr0,    vr1 // Permute cand_b to output refmvs_temporal_block
    vshuf.b         vr4,    vr4,        vr4,    vr5
    // v1 follows on v0, with another 3 full repetitions of the pattern.
    vshuf.b         vr1,    vr0,        vr0,    vr8 // 1, 2, 3, ... , 15, 16
    vshuf.b         vr5,    vr4,        vr4,    vr8 // 1, 2, 3, ... , 15, 16
    // v2 ends with 3 complete repetitions of the pattern.
    vshuf.b         vr2,    vr1,        vr0,    vr7
    vshuf.b         vr6,    vr5,        vr4,    vr7    // 4, 5, 6, 7, ... , 12, 13, 14, 15, 16, 17, 18, 19

    jirl            ra,     t5,         0
    bge             t1 ,    t4,         4f      // if (cand_b >= end)
    vor.v           vr0,    vr4,        vr4
    vor.v           vr1,    vr5,        vr5
    vor.v           vr2,    vr6,        vr6
    jirl            ra,     s0,         0
    blt             t3,     t4,         2b      // if (cand_b < end)

4:
    addi.d          a5,     a5,         -1      // h--
    addi.d          a7,     a7,         2       // y += 2
    add.d           a0,     a0,         a1      // rp += stride
    blt             zero,   a5,         1b

    ld.d        s0,         sp,         0x00
    ld.d        s1,         sp,         0x08
    ld.d        s2,         sp,         0x10
    ld.d        s3,         sp,         0x18
    ld.d        s4,         sp,         0x20
    addi.d      sp,         sp,         0x28

    move            ra,     t0
    jirl            zero,   ra,         0x00

10:
    addi.d          s1,     a3,         4
    vstelm.w        vr0,    a3,         0,      0   // .mv
    vstelm.b        vr0,    s1,         0,      4   // .ref
    addi.d          a3,     a3,         5
    jirl            zero,   ra,         0x00
20:
    addi.d          s1,     a3,         8
    vstelm.d        vr0,    a3,         0,      0   // .mv
    vstelm.h        vr0,    s1,         0,      4   // .ref
    addi.d          a3,     a3,         2 * 5
    jirl            zero,   ra,         0x00
40:
    vst             vr0,    a3,         0
    vstelm.w        vr1,    a3,         0x10,   0
    addi.d          a3,     a3,         4 * 5
    jirl            zero,   ra,         0x00

80:
    vst             vr0,    a3,         0
    vst             vr1,    a3,         0x10           // This writes 6 full entries plus 2 extra bytes
    vst             vr2,    a3,         5 * 8 - 16     // Write the last few, overlapping with the first write.
    addi.d          a3,     a3,         8 * 5
    jirl            zero,   ra,         0x00
160:
    addi.d          s1,     a3,         6 * 5
    addi.d          s2,     a3,         12 * 5
    vst             vr0,    a3,         0
    vst             vr1,    a3,         0x10          // This writes 6 full entries plus 2 extra bytes
    vst             vr0,    a3,         6 * 5
    vst             vr1,    a3,         6 * 5 + 16    // Write another 6 full entries, slightly overlapping with the first set
    vstelm.d        vr0,    s2,         0,      0     // Write 8 bytes (one full entry) after the first 12
    vst             vr2,    a3,         5 * 16 - 16   // Write the last 3 entries
    addi.d          a3,     a3,         16 * 5
    jirl            zero,   ra,         0x00

.save_tevs_tbl:
        .hword 16 * 12   // bt2 * 12, 12 is sizeof(refmvs_block)
        .hword .save_tevs_tbl - 160b
        .hword 16 * 12
        .hword .save_tevs_tbl - 160b
        .hword 8 * 12
        .hword .save_tevs_tbl -  80b
        .hword 8 * 12
        .hword .save_tevs_tbl -  80b
        .hword 8 * 12
        .hword .save_tevs_tbl -  80b
        .hword 8 * 12
        .hword .save_tevs_tbl -  80b
        .hword 4 * 12
        .hword .save_tevs_tbl -  40b
        .hword 4 * 12
        .hword .save_tevs_tbl -  40b
        .hword 4 * 12
        .hword .save_tevs_tbl -  40b
        .hword 4 * 12
        .hword .save_tevs_tbl -  40b
        .hword 2 * 12
        .hword .save_tevs_tbl -  20b
        .hword 2 * 12
        .hword .save_tevs_tbl -  20b
        .hword 2 * 12
        .hword .save_tevs_tbl -  20b
        .hword 2 * 12
        .hword .save_tevs_tbl -  20b
        .hword 2 * 12
        .hword .save_tevs_tbl -  20b
        .hword 1 * 12
        .hword .save_tevs_tbl -  10b
        .hword 1 * 12
        .hword .save_tevs_tbl -  10b
        .hword 1 * 12
        .hword .save_tevs_tbl -  10b
        .hword 1 * 12
        .hword .save_tevs_tbl -  10b
        .hword 1 * 12
        .hword .save_tevs_tbl -  10b
        .hword 1 * 12
        .hword .save_tevs_tbl -  10b
        .hword 1 * 12
        .hword .save_tevs_tbl -  10b
endfunc
