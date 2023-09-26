using System.Text.RegularExpressions;

namespace AVRAssembler;

public abstract class StringParser
{
    public static bool Is4BytesOperation(ref string binaryOp)
    {
        return Regex.IsMatch(binaryOp, "1001010[01]{5}110[01]") ||  // jmp
               Regex.IsMatch(binaryOp, "1001010[01]{5}111[01]");    // call
    }
    public static string ParseToBinaryString(string raw)
    {
        SwapBytes(ref raw); // меняем байты местами
        var op = Convert.ToString(Convert.ToUInt16(raw, 16), 2); // перводим в двоичный вид в строку
        return op.PadLeft(16, '0'); // добавляем нули для регулярки
    }

    public static string ConvertPc(int pc)
    {
        return Convert.ToString(pc, 16).PadLeft(2, '0');
    }

    private static void SwapBytes(ref string op)
    {
        var temp = op[..2];
        op = op[2..4];
        op += temp;
    }
}