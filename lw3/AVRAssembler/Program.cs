using System.Text.RegularExpressions;

namespace AVRAssembler;

internal abstract class Program
{
    public static void Main1(string[] args)
    {
        var op = StringParser.ParseToBinaryString("0C94") + StringParser.ParseToBinaryString("3400");
        var res = Regex.IsMatch(op, @"^1001010[01]{5}110[01]{17}$");
        res = Regex.IsMatch(op, @"^1001010[01]{5}110[01]{16}$");
        res = Regex.IsMatch(op, @"1001010[01]{5}110[01]{18}");
        res = Regex.IsMatch(op, "000011[01]{10}");
        res = Regex.IsMatch(op, @"^000011[01]{10}$");
    }
    public static void Main(string[] args)
    {
        var fs = Program.InitStream(/*args[0]*/ "assemblerstring.txt" );
        if (fs is null) return;

        var pc = 0;
        while (fs.EndOfStream is false)
        {
            var line = fs.ReadLine();
            if (line is null) break;
            line = line[9..^2]; // убираем ненужное
            
            for (var i = 0; i < line.Length / 4; i += 4)
            {
                Console.Write($"{StringParser.ConvertPc(pc)}: ");
                
                var raw = line[i..(i + 4)];
                Console.Write($"{raw[..2]} {raw[2..4]} ");
                
                var op = StringParser.ParseToBinaryString(raw);
                if (StringParser.Is4BytesOperation(ref op))
                {
                    i += 4;
                    pc += 2;
                    raw = line[i..(i+4)];
                    op += StringParser.ParseToBinaryString(raw);
                }
                op = InstructionMapper.Convert(op);
                Console.WriteLine(op);
                pc += 2;
            }
        }
    }
    
    
    private static StreamReader? InitStream(string filename)
    {
        StreamReader? fs = null;
        try
        {
            fs = new StreamReader(filename);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
        finally
        {
            if (fs is null)
            {
                fs?.Close();
                fs?.Dispose();
            }
        }
        return fs;
    }
}