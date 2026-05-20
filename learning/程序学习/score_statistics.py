def analyze_scores(scores):
    total_count = len(scores)
    highest_score = max(scores)
    lowest_score = min(scores)
    average_score = sum(scores) / total_count
    passed_count = len([score for score in scores if score >= 60])
    failed_count = len([score for score in scores if score < 60])
    excellent_count = len([score for score in scores if score > 85])

    return {
        "success": True,
        "total_count": total_count,
        "highest_score": highest_score,
        "lowest_score": lowest_score,
        "average_score": average_score,
        "passed_count": passed_count,
        "failed_count": failed_count,
        "excellent_count": excellent_count,
    }


def parse_scores(user_input):
    score_texts = user_input.split(",")
    scores = []

    try:
        for text in score_texts:
            score = int(text.strip())

            if score < 0 or score > 100:
                return {
                    "success": False,
                    "message": "输入错误：成绩必须在 0 到 100 之间",
                }

            scores.append(score)
    except ValueError:
        return {
            "success": False,
            "message": "输入错误：请只输入数字，并用英文逗号分隔",
        }

    if len(scores) == 0:
        return {
            "success": False,
            "message": "输入错误：请至少输入一个成绩",
        }

    return analyze_scores(scores)


def input_scores():
    while True:
        user_input = input("请输入成绩，用英文逗号分隔：")
        data = parse_scores(user_input)

        if data["success"]:
            return data

        print(data["message"])
        print("请重新输入。")


def print_result(data):
    print(f"总人数：{data['total_count']}")
    print(f"最高分：{data['highest_score']}")
    print(f"最低分：{data['lowest_score']}")
    print(f"平均分：{data['average_score']:.2f}")
    print(f"及格人数：{data['passed_count']}")
    print(f"不及格人数：{data['failed_count']}")
    print(f"优秀人数：{data['excellent_count']}")


if __name__ == "__main__":
    result = input_scores()
    print_result(result)
