
using System.Text.RegularExpressions;

namespace AVRAssembler;

internal abstract class InstructionMapper
{
    private static readonly Instruction[] Instructions = new[]
    {
        new Instruction() { Name = "add D,R",  Mask = "000011RDDDDDRRRR", Regex = "^000011[01]{10}$" },
        new Instruction() { Name = "subi D,K", Mask = "1010KKKKDDDDKKKK", Regex = "^1010[01]{12}$" },
        new Instruction() { Name = "suci D,K", Mask = "0100KKKKDDDDKKKK", Regex = "^0100[01]{12}$" },
        new Instruction() { Name = "jmp K", Mask = "1001010KKKKK110KKKKKKKKKKKKKKKKK", Regex = "^1001010[01]{5}110[01]{17}$" },
    };

    public static string? Convert(string binaryOp)
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
        var dict = new Dictionary<char, string>();
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
        
        // это чудо мутирует список в строку, с которой работаешь через лямбду
        return dict.Aggregate(instruction.Name, (current, pair) => current.Replace(pair.Key + "", pair.Value));
    }
}
