defmodule SynacorTest do
  use ExUnit.Case
  doctest Synacor

  @reg_0 32768
  @reg_1 32769

  test "write/read register" do
    Synacor.Memory.start_link
    Synacor.Memory.write(@reg_0, 1)
    assert 1 == Synacor.Memory.read(@reg_0)
  end

  test "read register indirect" do
    Synacor.Memory.start_link
    Synacor.Memory.write(@reg_0, 1)
    Synacor.Memory.write(0, @reg_0)
    assert 1 == Synacor.Memory.read(0)
  end

  test "registers nonzero jump" do
    Synacor.Memory.start_link
    Synacor.Memory.write(@reg_0, 1)
    Synacor.Memory.write(1, @reg_0)
    Synacor.Memory.write(2, 123)
    assert Synacor.eval(7, 0) == 123

    Synacor.Memory.write(@reg_0, 0)
    Synacor.Memory.write(1, @reg_0)
    Synacor.Memory.write(2, 123)
    assert Synacor.eval(7, 0) == 3
  end

  test "registers zero jump" do
    Synacor.Memory.start_link
    Synacor.Memory.write(@reg_0, 0)
    Synacor.Memory.write(1, @reg_0)
    Synacor.Memory.write(2, 123)
    assert Synacor.eval(8, 0) == 123

    Synacor.Memory.write(@reg_0, 1)
    Synacor.Memory.write(1, @reg_0)
    Synacor.Memory.write(2, 123)
    assert Synacor.eval(8, 0) == 3
  end
end
