
using System.ComponentModel.DataAnnotations;

namespace Pathfinder.Models
{
    public class BlockIdAttribute : ValidationAttribute
    {
        public BlockIdAttribute() { }

        public string GetErrorMessage() =>
            "Block IDs must be in the form <provider>:<name>";

        protected override ValidationResult IsValid(object value,
            ValidationContext validationContext)
        {
            var blockId = (string)value;

            if (blockId.Split(":").Length != 2)
            {
                return new ValidationResult(GetErrorMessage());
            }

            return ValidationResult.Success;
        }
    }
    public class PositiveAttribute : ValidationAttribute
    {
        public PositiveAttribute() { }

        public string GetErrorMessage() =>
            "Must be a positive number";

        protected override ValidationResult IsValid(object value,
            ValidationContext validationContext)
        {
            if ((long)value < 0)
            {
                return new ValidationResult(GetErrorMessage());
            }

            return ValidationResult.Success;
        }
    }
}
