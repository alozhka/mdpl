
using OfficeOpenXml;

namespace AVRAssembler;

abstract class XlsInstructionMapper
{
    public static ExcelWorksheet _sheet = 
        new ExcelPackage(new FileInfo("ASMCodes.xlsx")).Workbook.Worksheets[0];

    public static string Convert(string instance)
    {
        var a = _sheet.Cells[1,1];
        return a.ToString();
    }
}
