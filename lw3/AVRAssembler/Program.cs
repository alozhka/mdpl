namespace AVRAssembler;

internal abstract class Program
{ 
    public static void Main(string[] args)
    {
        var fs = InitStream(args[0]);
        if (fs is null) return;

        var pc = 0;
        while (fs.EndOfStream is false)
        {
            var line = fs.ReadLine();
            if (line is null) break;
            line = line[9..^2]; // убираем ненужное
            
            for (var i = 0; i < line.Length; i += 4)
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
                    Console.Write($"{raw[..2]} {raw[2..4]}".PadRight(12));
                    op += StringParser.ParseToBinaryString(raw);
                } else Console.Write("".PadRight(12));
                
                op = InstructionMapper.BinaryToInstruction(op);
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
            if (e is FileNotFoundException)
            {
                Console.WriteLine("Файл с таким именем не найден!");
            }
            else
            {
                Console.WriteLine(e);
            }
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