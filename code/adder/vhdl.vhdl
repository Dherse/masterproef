library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Adder is
Generic(n:integer:=8);
    Port ( Cin : in  STD_LOGIC;
           A : in  STD_LOGIC_VECTOR (n-1 downto 0);
           B : in  STD_LOGIC_VECTOR (n-1 downto 0);
           Result : out  STD_LOGIC_VECTOR (n downto 0));
end Adder;

architecture Behavioral of Adder is
   -- Full Adder component
    COMPONENT FullAdder
    PORT(
        A : IN std_logic;
        B : IN std_logic;
        Cin : IN std_logic;          
        S : OUT std_logic;
        Cout : OUT std_logic
        );
    END COMPONENT;
    signal carry : std_logic_vector(n downto 0);
begin
-- external carry input
carry(0) <= Cin;
-- Array of full adders
FA_array: For i in 0 to n-1 generate
    Inst_FullAdder: FullAdder PORT MAP(
        A => A(i),
        B => B(i),
        Cin => carry(i),
        S => Result(i),
        Cout => carry(i+1) -- connect the output carry to the input carry of the next FA
    );
end generate FA_array;
-- output carry
Result(n) <= carry(n);
end Behavioral;