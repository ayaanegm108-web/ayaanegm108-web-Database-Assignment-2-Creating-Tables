namespace DB_Ass_leetcode;
//Console.WriteLine("Hello, World!");
public class Program()
{
    public static void Main()
    {
        Solution solution = new Solution();
        int[] input = new int[] { 1, 2, 3, 4 };
        int [] result_01=solution.ProductExceptSelf(input);
        int [] result_02=solution.ProductExceptSelfConstantSpace(input);
        for (int i = 0; i < input.Length; i++)
        {
            Console.WriteLine(result_01[i]);
        }
       
        //solution.ProductExceptSelfConstantSpace(new int[] { 1, 2, 3, 4 });
    }
}