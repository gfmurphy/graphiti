class Graphiti::Sideload::ManyToMany < Graphiti::Sideload::HasMany
  def type
    :many_to_many
  end

  def through
    foreign_key.keys.first
  end

  def true_foreign_key
    foreign_key.values.first
  end

  def base_filter(parents)
    {true_foreign_key => ids_for_parents(parents).join(",")}
  end

  def infer_foreign_key
    raise "You must explicitly pass :foreign_key for many-to-many relationships, or override in subclass to return a hash."
  end

  def performant_assign?
    false
  end

  # Override in subclass
  def polymorphic?
    false
  end

  def apply_belongs_to_many_filter
    _self = self
    fk_type = parent_resource_class.attributes[:id][:type]
    fk_type = :hash if polymorphic?
    resource_class.filter true_foreign_key, fk_type do
      eq do |scope, value|
        _self.belongs_to_many_filter(scope, value)
      end
    end
  end

  def assign_each(parent, children)
    children.select do |c|
      match = ->(ct) { ct.send(true_foreign_key) == parent.send(primary_key) }
      c.send(through).any?(&match)
    end
  end
end
