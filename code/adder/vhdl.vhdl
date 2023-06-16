library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Adder is
Generic(n:integer:=8);
    Port ( Cin : in  STD_LOGIC;
           A : in  STD_LOGIC_VECTOR (n-1 downto 0);
           B : in  STD_LOGIC_VECTOR (n-1 downto 0);
           Result : out  STD_LOGIC_VECTOR (n downto 0));
           Cout : out STD_LOGIC
end Adder;

architecture Behavioral of Adder is
begin
    Result <= A + B + Cin;
    Cout <= Result(n);
end Behavioral;