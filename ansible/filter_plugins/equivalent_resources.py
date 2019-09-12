#!/usr/bin/python
'''

A filter to compare resource quantities for equivalence.

description:

    CPU quantities are specified in millicores or the number of cores. One core is the equivalent of 1000 millicores.

    The number of cores can be specified as either an integer >= 0, or a decimal fraction "nn.mmm".

    Values in millicores are an integer >= 0 with "m" as a suffix, e.g. "1000m" specifies 1000 millicores, which is
    equivalent to 1 Core.

    Memory quantities are specified in bytes with either SI suffixes (powers of 10) or their powers-of-two equivalents.

    SI Suffixes are:

       K - Kilo - 10**3:  1000
       M - Mega - 10**6:  1000,000
       G - Giga - 10**9:  1000,000,000
       T - Tera - 10**12: 1000,000,000,000
       P - Peta   10**15: 1000,000,000,000,000
       E - Exa    10**18: 1000,000,000,000,000,000

    The powers of two suffixes are:

       Ki - Kilo - 2**10: 1,024
       Mi - Mega - 2**20: 1,048,576
       Gi - Giga - 2**30: 1,073,741,824
       Ti - Tera - 2**40: 1,099,511,627,776
       Pi - Peta   2**50: 1,125,899,906,842,624
       Ei - Exa    2**60: 1,152,921,504,606,846,976

    A value such as "1.5Gi" is valid and is equivalent to "1536Mi". Floating point values result in unexpected
    behaviour. For example, ".555Gi" evaluates to 595.926,712.320 bytes.

    From experimentation with:

        $ oc set resources dc project-api -c=project-api --limits=cpu=1000m,memory=.555Gi --requests=cpu=50m,memory=50Mi

    ".555Gi" is a valid value and the values stored in the deployment configuration are:

        ...

        "resources": {
             "limits": {
                 "cpu": "1",
                 "memory": "595926712320m"
             },
             "requests": {
                 "cpu": "50m",
                 "memory": "50Mi"
             }
         },

          ...

    This appears to show that there is a unit of measurement, "millibyte" denoted by "595926712320m". This code does not
    accept fraction values for quantities of memory.

examples:

    - name: Set cpu filter variable for {{ microservice }}.
      set_fact:
        cpu_filter: "{{existing_cpu_limit}}, {{cpu_max}}"

    - name: Set dc resource changes needed flag for {{ microservice }}.
      set_fact:
        resource_changes_needed: "{{ cpu_filter | cpu_not_equivalent }}"

    - name: Set memory filter variable for {{ microservice }}.
      set_fact:
        memory_filter: "{{existing_memory_limit}}, {{memory_max}}"

    - name: Set dc resource changes needed flag for {{ microservice }}.
      set_fact:
        resource_changes_needed: "{{ memory_filter | memory_not_equivalent }}"

If the play book returns an error like this:

    TASK [Set max cpu resource changes needed flag for project-api.] 
    task path: ... omitted ...
    fatal: [localhost]: FAILED! => {}

    MSG:
    
    template error while templating string: no filter named 'cpu_not_equivalent'. ... omitted ...

The cause is likely to be a syntax error in this code.

author: "Steve Brown, Estafet Ltd."
'''

import re
import traceback
from __builtin__ import True, False

class FilterModule(object):

    # Pattern to split values argument.
    _SPLIT_PATTERN = re.compile('\s*?,\s*')

    # The regular expression to match quantities of memory.
    _MEMORY_PATTERN = re.compile('^([0-9]+?)([KMGTPE]i?)?$')

    # multipliers for quantities of memory.
    _SUFFIX_TO_MULTIPLIER = dict()

    _SUFFIX_TO_MULTIPLIER['K']  = 1000L
    _SUFFIX_TO_MULTIPLIER['Ki'] = 1024L
    _SUFFIX_TO_MULTIPLIER['M']  = 1000000L
    _SUFFIX_TO_MULTIPLIER['Mi'] = 1048576L
    _SUFFIX_TO_MULTIPLIER['G']  = 1000000000L
    _SUFFIX_TO_MULTIPLIER['Gi'] = 1073741824L
    _SUFFIX_TO_MULTIPLIER['T']  = 1000000000000L
    _SUFFIX_TO_MULTIPLIER['Ti'] = 1099511627776L
    _SUFFIX_TO_MULTIPLIER['P']  = 1000000000000000L
    _SUFFIX_TO_MULTIPLIER['Pi'] = 1125899906842624L
    _SUFFIX_TO_MULTIPLIER['E']  = 1000000000000000000L
    _SUFFIX_TO_MULTIPLIER['Ei'] = 1152921504606846976L

    def filters(self):
        """
        Get the filters that this class implements.

        Returns: The names of filters that this class implements. Each name maps to a method in this class.
        """
        return {
            'cpu_not_equivalent'    : self.cpu_not_equivalent,
            'memory_not_equivalent' : self.memory_not_equivalent
        }

    def cpu_not_equivalent(self, values):
        """
        Compare two CPU quantities for equivalence.

        All Exceptions are printed to stdout and then re-raised.

        Args:
            values (str): The two values as a comma-separated string.

        Returns:
            True if the values are not equivalent. False otherwise.
        """
        try:
            existing_value, new_value = self._split_values(values)

            if not new_value:
                raise ValueError("The new CPU value cannot be empty or None.")            
            
            if not existing_value:
                return True
            
            if existing_value == new_value:
                return False

            return self._cpu_not_equivalent(existing_value, new_value)
        except Exception as e:
            traceback.print_exc()
            print("ERROR: %s" % str(e))
            raise e

    def memory_not_equivalent(self, values):
        """
        Compare two Memory quantities for equivalence.

        All Exceptions are printed to stdout and then re-raised.

        Args:
            values (str): The two values as a comma-separated string.

        Returns:
            True if the values are not equivalent. False otherwise.
        """
        try:
            existing_value, new_value = self._split_values(values)

            if not new_value:
                raise ValueError("The new memory value cannot be empty or None.")            
            
            if not existing_value:
                return True
            
            if existing_value == new_value:
                return False

            return self._memory_not_equivalent(existing_value, new_value)
        except Exception as e:
            traceback.print_exc()
            print("ERROR: %s" % str(e))
            raise e

    def _split_values(self, values):
        """
        Split the give values.

        Args:
            values (str): The two values as a comma-separated string.

        Returns:
            A tuple of two strings.
        """

        # Strings in _values are Unicode objects.
        _values = FilterModule._SPLIT_PATTERN.split(values, maxsplit=1)

        if len(_values) != 2:
            raise ValueError("There must be exactly two values in \"%s\"." % values)

        existing_value, new_value = _values
        return existing_value, new_value

    def _cpu_not_equivalent(self, existing_value, new_value):
        """
        Determine whether or not two CPU resource quantities are not equivalent.

        Args:
            cpu1 (str): The first value.
            cpu2 (str): The second value.

        Returns:
            bool: True if cpu1 and cpu2 are not equivalent: i.e. they represent different quantities of millicores.


        """
        cpu1_millicores = self._to_millicores(existing_value)
        cpu2_millicores = self._to_millicores(new_value)
        return cpu1_millicores != cpu2_millicores

    def _to_millicores(self, value):
        """
        Convert a string to the number of millicores.

        Quantities are specified in millicores or the number of cores. One core is the equivalent of 1000 millicores.

        The number of cores can be specified as either an integer >= 0, or a decimal fraction "nn.mmm".

        Values in millicores are an integer >= 0 with "m" as a suffix, e.g. "1000m" specifies 1000 millicores.


        Args:
            value (str): The value to convert.

        Returns:
            int: The number of millicores represented by value.


        """
        if not value:
            raise ValueError("\"%s\" is not a valid CPU quantity (empty)." % value)

        if value.endswith('m'):
            quantity = value[0 : -1]
            if quantity.isdigit():
                return int(quantity)
            raise ValueError("The value \"%s\" is  an invalid number of millicores (not all digits).")

        if value.find(".") != -1:
            return self._number_to_millicores(value)

        if not value.isdigit():
            raise ValueError("\"%s\" is not a valid CPU quantity (not all digits)." % value)

        result = int(value) * 1000
        return result

    def _number_to_millicores(self, value):
        """
        Convert a decimal number to the number of millicores.

        The number of cores is a decimal fraction "nn.mmm".

        Args:
            value (str): The value to convert.

        Returns:
            int: The number of millicores represented by value.


        """
        parts = value.split(".", 1)
        whole = parts[0]
        no_whole = not whole

        no_fraction = True
        fraction = None
        if len(parts) == 2:
            fraction = parts[1]
            no_fraction = not fraction

        if no_whole and no_fraction:
            raise ValueError("\"%s\" is not a valid CPU quantity (invalid decimal number)." % value)

        if no_whole:
            whole = '0'
        elif not whole.isdigit():
            raise ValueError("\"%s\" is not a valid CPU quantity (integer part not all digits)." % value)

        if fraction:
            if len(fraction) > 3:
                raise ValueError("\"%s\" is not a valid CPU quantity (more than three decimal places)." % value)
            elif not fraction.isdigit():
                raise ValueError("\"%s\" is not a valid CPU quantity (fraction not all digits)." % value)
        else:
            fraction = '0'

        value = "%s.%s" % (whole, fraction)

        return int(float(value) * 1000.0)

    def _memory_not_equivalent(self, memory1, memory2):
        """
        Determine whether or not two memory resource quantities are not equivalent.

        Args:
            memory1 (str): The first value.
            memory2 (str): The second value.

        Returns:
            bool: True if memory1 and memory2 are not equivalent: i.e. they represent the different quantities of bytes.


        """
        suffix1, existing_value = self.get_suffix_and_value(memory1)
        suffix2, new_value = self.get_suffix_and_value(memory2)
        memory1_bytes = self.to_bytes(existing_value, suffix1)
        memory2_bytes = self.to_bytes(new_value, suffix2)
        return memory1_bytes != memory2_bytes

    def get_suffix_and_value(self, value):
        """
        Get the quantity and suffix from the supplied memory value.

        Args:
            value (str): The value, possibly with a suffix.

        Returns:
            str, long: The suffix and the quantity. The suffix will be an empty string if value has no suffix.


        """

        matches = FilterModule._MEMORY_PATTERN.match(value)

        if not matches:
            raise ValueError("\"%s\" is not a valid Memory quantity." % value)

        quantity = matches.group(1)
        
        # Will be None if there is no suffix
        suffix = matches.group(2)

        # This will happen only if _MEMORY_PATTERN is incorrect.
        if not quantity.isdigit():
            raise ValueError("\"%s\" is not a valid Memory quantity. The quantity \"%s\" is not valid." % \
                                             (value, quantity))

        # Just convert the value if there is no suffix.
        if suffix is None:
            if quantity != value:
                # This will happen only if a if _MEMORY_PATTERN is incorrect.
                raise ValueError("\"%s\" is not a valid Memory quantity. The quantity \"%s\" is not valid." % \
                                             (value, quantity))
            suffix = ""
        elif not FilterModule._SUFFIX_TO_MULTIPLIER.has_key(suffix):
            # This will happen only if:
            # A suffix is not included in _MEMORY_PATTERN or _SUFFIX_TO_MULTIPLIER, or
            # _MEMORY_PATTERN is incorrect.
            raise ValueError("\"%s\" is not a valid Memory quantity. The suffix \"%s\" is not valid." % \
                                             (value, suffix))
        return suffix, long(quantity)

    def to_bytes(self, value, suffix):
        """
        Convert a quantity of memory and a suffix to a number of bytes.

        Args:
            value (long):   The quantity to convert.
            suffix (str):   The suffix specifying the multiplier. If suffix is an empty string or None, value does
                            not need to be converted.

        Returns:
            long: The number of bytes represented by value and suffix.


        """
        
        if suffix:
            multiplier = FilterModule._SUFFIX_TO_MULTIPLIER[suffix]
    
            quantity = value * multiplier
            return quantity
        return value