
namespace AVRAssembler;

internal abstract class InstructionMapper
{
    private static readonly Instruction[] Instructions = new[]
    {
        new Instruction() { Name = "add d,r",  Regex = "000011rdddddrrrr" },
        new Instruction() { Name = "subi d,K", Regex = "1010([01]{4}([01]{4})[01]{4})" }, //1010KKKKddddKKKK
        new Instruction() { Name = "suci d,K", Regex = "0100([01]{4}([01]{4})[01]{4})" },
        new Instruction() { Name = "jmp d", Regex = "1001010kkkkk110kkkkkkkkkkkkkkkkk" },
    };

    public static string? Convert(string instance)
    {
        var a = Instructions.FirstOrDefault(command => command.Regex == instance);
        return a?.Name;
    }
}
