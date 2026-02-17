#include <gtest/gtest.h>

#include <shared/ByteBuffer.h>

TEST(ByteBufferTest, ReadDoesNotAdvanceOnFailure)
{
	ByteBuffer buf;
	buf.append<uint16_t>(0xABCD);
	buf.rpos(0);

	(void) buf.read<uint32_t>();
	EXPECT_EQ(buf.rpos(), 0u);

	auto v16 = buf.read<uint16_t>();
	EXPECT_EQ(v16, static_cast<uint16_t>(0xABCD));
	EXPECT_EQ(buf.rpos(), sizeof(uint16_t));
}

TEST(ByteBufferTest, ReadStringDoesNotConsumeHeaderOnFailure_DByte)
{
	ByteBuffer buf;
	buf.DByte();
	buf.append<uint16_t>(5); // length header only; payload missing
	buf.rpos(0);

	std::string out;
	EXPECT_FALSE(buf.readString(out));
	EXPECT_TRUE(out.empty());
	EXPECT_EQ(buf.rpos(), 0u);
}

TEST(ByteBufferTest, ReadStringDoesNotConsumeHeaderOnFailure_SByte)
{
	ByteBuffer buf;
	buf.SByte();
	buf.append<uint8_t>(5); // length header only; payload missing
	buf.rpos(0);

	std::string out;
	EXPECT_FALSE(buf.readString(out));
	EXPECT_TRUE(out.empty());
	EXPECT_EQ(buf.rpos(), 0u);
}

