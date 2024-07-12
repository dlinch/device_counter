class ApplicationCreator
  attr_reader :store, :record

  delegate :exist?, :fetch, :increment, :read, :read_multi, :write, to: :store
  delegate :valid?, to: :record

  def initialize(store)
    @store = store
  end

  # Mostly empty, but a good place to store any kind of tracing, hooks, event firing, RBAC/permissions checks, etc.
  def create(params = {})
    @result = perform(params)

    @result
  end

  def call
    raise NotImplementedError.new("Must implement the call method")
  end

  private

  def invalid?
    !valid?
  end

  def formatted_errors
    record.errors.full_messages.to_sentence
  end
end
