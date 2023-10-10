using System.Text.RegularExpressions;

namespace AVRAssembler;


using InstructionMap = Dictionary<char, string>;

internal abstract class InstructionMapper
{
    private const int Padding = 20;

    /**
     * <summary>
     * Для своих значений свои ключ в маске:
     * A - адрес в памяти (16 бит)
     * N - адрес в памяти (8 бит)
     * P - адрес порта
     * K - константа (в 10 системе счисления)
     * X - константа (в 16 системе счисления)
     * L - номер регистра (начиная с 16)
     * D, R - номер регистра (начиная с 0)
     * </summary>
     */
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
        new() { Name = "sbic P,K", Mask = "10011001PPPPPKKK", Regex = "^10011001[01]{8}$" },
        new() { Name = "cli", Mask = "1001010011111000", Regex = "^1001010011111000$" },
        new() { Name = "nop", Mask = "0000000000000000", Regex = "^0000000000000000$" },
    };

    /**
     * <summary>
     * Переводит двоичную строку в ассемблерную команду
     * </summary>
     * <returns>string?</returns>
     */
    public static string? BinaryToInstruction(string binaryOp, int programCounter)
    {
        var instruction = MatchInstructionByRegex(binaryOp);
        return instruction is null ? null : InstructionToString(instruction, binaryOp, programCounter);
    }

    /**
     * <summary>
     * Возвращает первую инструкцию, удовлетворяющую регулярному выражению или ничего
     * </summary>
     * <returns>Instruction?</returns>
     */
    private static Instruction? MatchInstructionByRegex(string op)
    {
        return Instructions.FirstOrDefault(instr => Regex.IsMatch(op, instr.Regex));
    }

    /**
     * <summary>
     * Переводит инструкцию
     * </summary>
     */
    private static string InstructionToString(Instruction instruction, string op, int programCounter)
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

        var commentary = NumberConversion(ref dict, programCounter);    // получаем комментарий
        
        // это чудо мутирует список в строку и добавляет комментарий в конец
        var result = dict.Aggregate(instruction.Name, (current, pair) => current.Replace(pair.Key + "", pair.Value));
        result = result.PadRight(Padding);
        result += commentary;
        return result;
    }

    /**
     * <summary>
     * Переводит двоичное число в зависимости от того, где оно используется(по его ключу)
     * </summary>
     */
    private static string NumberConversion(ref InstructionMap dict, int pc)
    {
        var comment = "";
        if (dict.ContainsKey('A'))
        {
            var num = Convert.ToString(Convert.ToUInt32(dict['A'], 2) << 1, 16).ToUpper();
            dict['A'] = $"0x{num}";
            comment = $"; 0x{num}";
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
            var binary = Convert.ToUInt16(dict['P'], 2);
            dict['P'] = "0x" + Convert.ToString(binary, 16).ToUpper();
            comment = $"; {Convert.ToString(binary)}";
        }
        if (dict.ContainsKey('K'))
        {
            dict['K'] = Convert.ToString(Convert.ToUInt16(dict['K'], 2));
        }
        if (dict.ContainsKey('X'))
        {
            var binary = Convert.ToUInt16(dict['X'], 2);
            dict['X'] = "0x" + Convert.ToString(binary, 16).ToUpper();
            comment = $"; {Convert.ToString(binary, 10)}";
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
                dict['N'] = "-" + Convert.ToString(binary).ToUpper();
                comment = $"; 0x{Convert.ToString(pc - binary + 2, 16).ToUpper()}";
            }
            else
            {
                var binary = Convert.ToInt16(dict['N'], 2) << 1;
                dict['N'] = "+" + Convert.ToString(binary).ToUpper();
                comment =  $"; 0x{Convert.ToString(pc + binary + 2, 16).ToUpper()}";
            }
        }

        return comment;
    }
}
