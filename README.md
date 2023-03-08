[![Gem Version](https://badge.fury.io/rb/data_class_factory.svg)](https://badge.fury.io/rb/data_class_factory)

# Data class factory

Backport `Data.define` for Ruby 2.7, 3.0, 3.1 :)

## Installation

```ruby
gem 'data_class_factory'
```

and then `bundle install`

## Usage

```ruby
require 'data_class_factory'

Point = Data.define(:x, :y) do
  def norm
    Math.sqrt(x * x + y * y)
  end
end
p1 = Point.new(x: 3, y: 4)
p2 = Point.new(x: 3, y: 4)
p1 == p2 # => true
```

Most features of the data class are ported. See https://docs.ruby-lang.org/en/3.2/Data.html for checking the original spec of `Data`.

One difference is that backported Data class intentionally accepts only keyword arguments for `.new` while original Data class accepts both positional args and keyword args.

```ruby
Point = Data.define(:x, :y) do
  def norm
    Math.sqrt(x * x + y * y)
  end
end

# raises ArgumentError
#          wrong number of arguments (given 2, expected 0)
p1 = Point.new(3, 4)

p1 = Point.new(x: 3, y: 4) # works well :)
```

### aliasing

REMARK this gem removes `Data` [defined on Ruby 2.7](https://ruby-doc.org/core-2.7.0/Data.html), and respects original `Data` on Ruby >= 3.2. If you prefer using this gem also on Ruby >= 3.2, choose another name like this.

```ruby
MyDataClass = DataClassFactory.define_factory_class
```

We can use the aliased class as usual like below.

```ruby
Point = MyDataClass.define(:x, :y) do
  def norm
    Math.sqrt(x * x + y * y)
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DataClassFactory project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](./CODE_OF_CONDUCT.md).
