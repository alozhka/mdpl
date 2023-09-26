using System.Text.RegularExpressions;

namespace AVRAssembler;


using InstructionMap = Dictionary<char, string>;

internal abstract class InstructionMapper
{
    
    private static readonly Instruction[] Instructions =
    {
        new() { Name = "add D,R",  Mask = "000011RDDDDDRRRR", Regex = "^000011[01]{10}$" },
        new() { Name = "subi L,X", Mask = "1010XXXXLLLLXXXX", Regex = "^0101[01]{12}$" },
        new() { Name = "suci D,X", Mask = "0100XXXXDDDDXXXX", Regex = "^0100[01]{12}$" },
        new() { Name = "jmp A", Mask = "1001010AAAAA110AAAAAAAAAAAAAAAAA", Regex = "^1001010[01]{5}110[01]{17}$" },
        new() { Name = "call A", Mask = "1001010AAAAA111AAAAAAAAAAAAAAAAA", Regex = "^1001010[01]{5}111[01]{17}$" },
        new() { Name = "eor D,R", Mask = "001001RDDDDDRRRR", Regex = "^001001[01]{10}$" },
        new() { Name = "out P,R", Mask = "10111PPRRRRRPPPP", Regex = "^10111[01]{11}$" },
        new() { Name = "ldi L,X", Mask = "1110XXXXLLLLXXXX", Regex = "^1110[01]{12}$" },
        new() { Name = "sbi P,K", Mask = "10011010PPPPPKKK", Regex = "^10011010[01]{8}$" },
        new() { Name = "breq .N", Mask = "111100NNNNNNN001", Regex = "^111100[01]{7}001$" },
        new() { Name = "brne .N", Mask = "111101NNNNNNN001", Regex = "^111101[01]{7}001$" },
        new() { Name = "rjmp .N", Mask = "1100NNNNNNNNNNNN", Regex = "^1100[01]{12}$" },
        new() { Name = "cbi P,K", Mask = "10011000PPPPPKKK", Regex = "^10011000[01]{8}$" },
        new() { Name = "cli", Mask = "1001010011111000", Regex = "^1001010011111000$" },
        new() { Name = "nop", Mask = "0000000000000000", Regex = "^0000000000000000$" },
    };

    public static string? BinaryToInstruction(string binaryOp)
    {
        var instruction = MatchInstructionByRegex(binaryOp);
        return instruction is null ? null : InstructionToString(instruction, binaryOp);
    }

    
    private static Instruction? MatchInstructionByRegex(string op)
    {
        return Instructions.FirstOrDefault(instr => Regex.IsMatch(op, instr.Regex));
    }

    private static string InstructionToString(Instruction instruction, string op)
    {
        var mask = instruction.Mask;
        var dict = new InstructionMap();
        for (var i = 0; i < op.Length; i++)
        {
            if (char.IsNumber(mask[i])) continue; // проходим если есть маска

            if (!dict.ContainsKey(mask[i]))
            {
                dict.Add(mask[i], op[i] + "");
            }
            else
            {
                dict[mask[i]] += op[i];
            }
        }

        NumberConversion(ref dict);
        
        // это чудо мутирует список в строку, с которой работаешь через лямбду
        return dict.Aggregate(instruction.Name, 
                (current, pair) => current.Replace(pair.Key + "", pair.Value)
            );
    }

    private static void NumberConversion(ref InstructionMap dict)
    {
        if (dict.ContainsKey('A'))
        {
            dict['A'] = "0x" + Convert.ToString(Convert.ToUInt32(dict['A'], 2) << 1, 16);
        }
        if (dict.ContainsKey('R'))
        {
            dict['R'] = "r" + Convert.ToString(Convert.ToUInt16(dict['R'], 2));
        }
        if (dict.ContainsKey('D'))
        {
            dict['D'] = "r" + Convert.ToString(Convert.ToUInt16(dict['D'], 2));
        }
        if (dict.ContainsKey('P'))
        {
            dict['P'] = "0x" + Convert.ToString(Convert.ToUInt16(dict['P'], 2), 16);
        }
        if (dict.ContainsKey('K'))
        {
            dict['K'] = Convert.ToString(Convert.ToUInt16(dict['K'], 2));
        }
        if (dict.ContainsKey('X'))
        {
            dict['X'] = "0x" + Convert.ToString(Convert.ToUInt16(dict['X'], 2), 16);
        }
        if (dict.ContainsKey('L'))
        {
            dict['L'] = "r" + Convert.ToString(Convert.ToUInt16(dict['L'], 2) + 16);
        }

        if (dict.ContainsKey('N'))
        {
            if (dict['N'][0] == '1') // если отрицательное
            {
                var offset = new string(dict['N'].Select(ch => ch == '0' ? '1' : '0').ToArray());
                var binary = (Convert.ToInt16(offset, 2) + 1) * 2;
                dict['N'] = "-" + Convert.ToString(binary);
            }
            else
            {
                dict['N'] = "+" + Convert.ToString(Convert.ToInt16(dict['N'], 2) << 1);
            }
        }
    }
}
