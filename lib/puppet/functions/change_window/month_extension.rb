##
# Provides custom extensions to add week_of_month to Time objects
#
# The extension code was obtained in part from week-of-month (https://github.com/sachin87/week-of-month)
#
# Licensed under MIT, attributed to original author as follows:
# The MIT License (MIT)
#
# Copyright (c) 2012-2017 Sachin Singh
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# Creative Commons License

module TimeExtensions
  module Time
    module Month
      MONTH_WITH_DAY = { january: 31, february: 28, march: 31,
                         april: 30, may: 31, june: 30, july: 31,
                         august: 31, september: 30, october: 31,
                         november: 30, december: 31 }.freeze

      # hash containing month names with their sequence
      MONTH_WITH_SEQUENCE = { january: 1, february: 2, march: 3,
                              april: 4, may: 5, june: 6, july: 7,
                              august: 8, september: 9, october: 10,
                              november: 11, december: 12 }.freeze

      # this code generates method named like january?..december?
      # to check whether a month is january or march? etc.
      # @return [Boolean]
      MONTH_WITH_DAY.keys.each do |month_name|
        define_method((month_name.to_s + '?').to_sym) do
          MONTH_WITH_SEQUENCE[month_name] == month
        end
      end

      # returns week of month for a given date
      # Date.new(2012,11,15).week_of_month
      #   => 3
      # @return [Fixnum]
      def week_of_month
        week_split.each_with_index do |o, i|
          return (i + 1) if o.include?(day)
        end
      end

      def week_split
        days_array.each_slice(7).to_a
      end

      def days_array
        day = beginning_of_month.to_date.wday
        day = day.zero? ? 6 : day - 1
        array = []
        array[day] = 1
        (2..ending_of_month.mday).each { |i| array << i }
        array
      end

      def beginning_of_month
        self.class.new(year, month, 1)
      end

      def ending_of_month
        self.class.new(year, month, last_day_of_month)
      end

      def last_day_of_month
        if leap? && february?
          29
        else
          MONTH_WITH_DAY[MONTH_WITH_SEQUENCE.key(month)]
        end
      end

      def leap?
        to_date.leap?
      end
    end
  end
end