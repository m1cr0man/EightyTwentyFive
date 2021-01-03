using System;
using System.Collections.Generic;
using System.Linq;

namespace Pathfinder.Models
{
    public class Base62
    {
        private static readonly char[] BaseChars =
            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".ToCharArray();
        private static readonly Dictionary<char, int> CharValues = BaseChars
                .Select((c, i) => new { Char = c, Index = i })
                .ToDictionary(c => c.Char, c => c.Index);

        public static string ConvertLong(long value)
        {
            long targetBase = BaseChars.Length;

            // Determine exact number of characters to use.
            char[] buffer = new char[Math.Max(
                        (int)Math.Ceiling(Math.Log(value + 1, targetBase)), 1)];

            var i = buffer.Length;
            do
            {
                buffer[--i] = BaseChars[value % targetBase];
                value = value / targetBase;
            }
            while (value > 0);

            return new string(buffer, i, buffer.Length - i);
        }
    }
}
