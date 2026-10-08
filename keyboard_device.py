import sys
import select


def is_key_pressed(prompt: str, timeout_s: float):
    """
    input()-tyylinen syöte timeoutilla.
    Palauttaa:
      - merkkijonon, jos käyttäjä ehti syöttää rivin (Enter)
      - None, jos timeout tuli
    """
    print(prompt, end="", flush=True)

    rlist, _, _ = select.select([sys.stdin], [], [], timeout_s)
    if rlist:
        return sys.stdin.readline().rstrip("\n")
    return None


if __name__ == "__main__":
    value = is_key_pressed("Anna jotain 2ms sisään: ", 0.002)
    while True:
        value = is_key_pressed("", 0.002)
        if value is None:
            pass
        else:
            print(f"\nSait: {value}")