namespace AVRAssembler;

internal abstract class Program
{
    public static void Main(string[] args)
    {
        var fs = InitStream(args[0]);
        if (fs is null) return;
        
        
        var pc = 0;                                         // Ставим счётчик на 0
        while (fs.EndOfStream is false)                     // Проходимся по всем строкам до конца файла
        {
            var line = fs.ReadLine();                 // Считывание, если строки нет, то выходим из цикла
            if (line is null) break;
            
            line = line[9..^2];                             // Оставляем только команды
            
            for (var i = 0; i < line.Length; i += 4)                      // Смотрим каждую команду
            {
                Console.Write($"{StringParser.ConvertPc(pc)}: ");
                
                var raw = line[i..(i + 4)];
                Console.Write($"{raw[..2]} {raw[2..4]} ");                // Парсим, записывем биты
                
                var op = StringParser.ParseToBinaryString(raw);     // Переводим в двоичную строку
                if (StringParser.Is4BytesOperation(ref op))               // Если операция в 4 байта, то берём ещё 2
                {
                    i += 4;
                    pc += 2;                                              // Прибавляем счётчик
                    raw = line[i..(i+4)];
                    Console.Write($"{raw[..2]} {raw[2..4]}".PadRight(12));
                    op += StringParser.ParseToBinaryString(raw);
                } else Console.Write("".PadRight(12));                    // Иначе печатаем отступ
                
                op = InstructionMapper.BinaryToInstruction(op);           // Переводим двоичную строку в готовый код
                Console.WriteLine(op);                                    // Печатаем
                pc += 2;                                                  // Не забываем про счётчик
            }
        }
    }
    
    /**
     * <summary>
     * Открывает файл для чтения по строкам
     * </summary>
     * <returns>StreamReader?</returns>
     */
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