using System.Text.RegularExpressions;

namespace AVRAssembler;

internal abstract class Program
{
    public static void Main(string[] args)
    {
        var fs = Program.InitStream(/*args[0]*/ "assemblerstring.txt" );
        if (fs is null) return;

        while (fs.EndOfStream is false)
        {
            var line = fs.ReadLine();
            if (line is null) break;
            line = line[9..^2];
            var raw = line[..4];
            // то что получили с файла
            raw = "3040";

            ParseOperator(raw);
        }
            
        
    }
    private static string ParseOperator(string raw)
    {
        Program.SwapBytes(ref raw); // меняем биты местами
        var op = Convert.ToString(Convert.ToUInt16(raw, 16), 2); // перводим в двоичный вид в строку
        op = op.PadLeft(16, '0'); // добавляем нули для ргеулярки
        
        
        var match = Regex.Matches(op, "0100([01]{4}([01]{4})[01]{4})");
        
        return "";
    }

    private static void SwapBytes(ref string op)
    {
        var temp = op[..2];
        op = op[2..4];
        op += temp;
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