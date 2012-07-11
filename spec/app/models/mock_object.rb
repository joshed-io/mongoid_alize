# explicit mock object class due to this issue - https://github.com/btakita/rr/issues/44
class MockObject
  def to_ary
    nil
  end
end
