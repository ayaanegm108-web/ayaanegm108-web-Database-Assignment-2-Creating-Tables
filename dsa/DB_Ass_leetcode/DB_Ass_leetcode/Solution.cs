using System;
using System.Collections.Generic;
using System.Text;

namespace DB_Ass_leetcode
{
    public class Solution
    {
        public int[] ProductExceptSelf(int[] nums)
        {
            int n = nums.Length;
            int[] prefix = new int[n];
            int[] suffix = new int[n];
            int[] answer = new int[n];

            prefix[0] = 1;                       // nothing on the left of index 0
            for (int i = 1; i < n; i++)
                prefix[i] = prefix[i - 1] * nums[i - 1];

            suffix[n - 1] = 1;                   // nothing on the right of the last index
            for (int i = n - 2; i >= 0; i--)
                suffix[i] = suffix[i + 1] * nums[i + 1];

            for (int i = 0; i < n; i++)
                answer[i] = prefix[i] * suffix[i];

            return answer;
        }
        public int[] ProductExceptSelfConstantSpace(int[] nums)
        {
            int n = nums.Length;
            int[] answer = new int[n];

            answer[0] = 1;
            for (int i = 1; i < n; i++)
                answer[i] = answer[i - 1] * nums[i - 1];   // answer[i] = prefix[i]

            int suffix = 1;                                // product of everything right of i
            for (int i = n - 1; i >= 0; i--)
            {
                answer[i] *= suffix;                       // prefix[i] * suffix
                suffix *= nums[i];                         // extend the suffix to include nums[i]
            }

            return answer;
        }
    }
}
