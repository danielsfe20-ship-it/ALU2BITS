# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

def pack_inputs(a, b, op):
    """Empaqueta a[2:0], b[2:0], op[1:0] en ui_in[7:0]"""
    return (op << 6) | (b << 3) | a

@cocotb.test()
async def test_alu_2bit(dut):
    """Prueba completa de la ALU 2 bits"""

    # Reloj (aunque el diseño es combinacional, el testbench lo necesita)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Inicialización
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # =====================================================
    # Casos de prueba
    # =====================================================

    test_cases = [
        # (a, b, op, expected_y, expected_c, expected_z, expected_e, descripción)
        # SUMA (op = 00)
        (1, 2, 0b00, 3, 0, 0, 0, "1 + 2 = 3"),
        (3, 4, 0b00, 7, 0, 0, 0, "3 + 4 = 7"),
        (5, 5, 0b00, 10, 0, 0, 0, "5 + 5 = 10"),
        (0, 0, 0b00, 0, 0, 1, 0, "0 + 0 = 0 (zero)"),

        # RESTA (op = 01)
        (5, 2, 0b01, 3, 0, 0, 0, "5 - 2 = 3"),
        (2, 5, 0b01, 13, 1, 0, 0, "2 - 5 → préstamo (dif[3]=1)"),  # 2-5 en 4 bits con extensión
        (4, 4, 0b01, 0, 0, 1, 0, "4 - 4 = 0 (zero)"),

        # MULTIPLICACIÓN (op = 10)
        (2, 3, 0b10, 6, 0, 0, 0, "2 * 3 = 6"),
        (3, 3, 0b10, 9, 0, 0, 0, "3 * 3 = 9"),
        (5, 5, 0b10, 25 & 0xF, 1, 0, 0, "5 * 5 = 25 → y=9, c=1"),  # 25 = 0b011001 → y=1001, c=1
        (0, 7, 0b10, 0, 0, 1, 0, "0 * 7 = 0 (zero)"),

        # DIVISIÓN (op = 11)
        (6, 2, 0b11, 3, 0, 0, 0, "6 / 2 = 3"),
        (7, 3, 0b11, 2, 0, 0, 0, "7 / 3 = 2"),
        (5, 1, 0b11, 5, 0, 0, 0, "5 / 1 = 5"),
        (4, 0, 0b11, 0, 0, 0, 1, "4 / 0 → error"),
        (0, 5, 0b11, 0, 0, 1, 0, "0 / 5 = 0 (zero)"),
    ]

    for a, b, op, exp_y, exp_c, exp_z, exp_e, desc in test_cases:
        ui_val = pack_inputs(a, b, op)
        dut.ui_in.value = ui_val

        # Esperar un poco (diseño combinacional)
        await Timer(1, units="us")
        await ClockCycles(dut.clk, 1)

        # Leer salidas
        y = int(dut.uo_out.value) & 0x0F          # bits [3:0]
        c = (int(dut.uo_out.value) >> 4) & 1      # bit 4
        z = (int(dut.uo_out.value) >> 5) & 1      # bit 5
        e = (int(dut.uo_out.value) >> 6) & 1      # bit 6

        # Comprobar
        assert y == exp_y, f"[{desc}] y incorrecto: obtuvo {y}, esperaba {exp_y}"
        assert c == exp_c, f"[{desc}] c incorrecto: obtuvo {c}, esperaba {exp_c}"
        assert z == exp_z, f"[{desc}] z incorrecto: obtuvo {z}, esperaba {exp_z}"
        assert e == exp_e, f"[{desc}] e incorrecto: obtuvo {e}, esperaba {exp_e}"

        dut._log.info(f"PASS: {desc} → y={y}, c={c}, z={z}, e={e}")

    dut._log.info("Todas las pruebas de la ALU pasaron correctamente")
