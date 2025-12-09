import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test_my_reg(dut):
    """Test the my_reg module."""

    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst.value = 1
    dut.d_in.value = 0
    await RisingEdge(dut.clk)

    # Release reset
    dut.rst.value = 0
    dut.load.value = 1
    await RisingEdge(dut.clk)

    # Test writing and reading values
    test_values = [0x1234, 0xABCD, 0xFFFF, 0x0000, 0x7FFF, 0x8000]

    for val in test_values:
        dut.d_in.value = val
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        assert dut.q_out.value == val, f"Expected {val:#06x}, got {int(dut.q_out.value):#06x}"