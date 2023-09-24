using System.Text.RegularExpressions;

namespace AVRAssembler;

public sealed class Instruction
{
    public string Name { get; init; } = "";
    public string Regex { get; init; } = "";
}