#!/usr/bin/env python3
"""Generate Sankhya-branded PDFs from simple Markdown text."""

from __future__ import annotations

import argparse
import html
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    KeepTogether,
    ListFlowable,
    ListItem,
    PageTemplate,
    PageBreak,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"
FIRST_PAGE_BG = ASSETS / "primeira-pagina.jpg"
LOGO = ASSETS / "logo-sankhya.png"
FOOTER_STRIP = ASSETS / "faixa-rodape.png"

PAGE_W, PAGE_H = A4
SANKHYA_GREEN = colors.HexColor("#007A3D")
DARK_GREEN = colors.HexColor("#005C2F")
BODY = colors.HexColor("#111827")
MUTED = colors.HexColor("#334155")


def register_fonts() -> tuple[str, str]:
    """Register Roboto if available; otherwise use a local Unicode-safe font."""
    regular = ASSETS / "Roboto-Regular.ttf"
    bold = ASSETS / "Roboto-Bold.ttf"
    if regular.exists() and bold.exists():
        pdfmetrics.registerFont(TTFont("Roboto", str(regular)))
        pdfmetrics.registerFont(TTFont("Roboto-Bold", str(bold)))
        return "Roboto", "Roboto-Bold"
    arial_unicode = Path("/System/Library/Fonts/Supplemental/Arial Unicode.ttf")
    arial_bold = Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf")
    if arial_unicode.exists() and arial_bold.exists():
        pdfmetrics.registerFont(TTFont("ArialUnicode", str(arial_unicode)))
        pdfmetrics.registerFont(TTFont("ArialUnicode-Bold", str(arial_bold)))
        return "ArialUnicode", "ArialUnicode-Bold"
    # Linux (VM do Cowork): LiberationSans cobre acentos e travessao; licao MEDCHAP 25/09/2026.
    for base in (Path("/usr/share/fonts/truetype/liberation"), Path("/usr/share/fonts/truetype/liberation2")):
        lib_regular, lib_bold = base / "LiberationSans-Regular.ttf", base / "LiberationSans-Bold.ttf"
        if lib_regular.exists() and lib_bold.exists():
            pdfmetrics.registerFont(TTFont("LiberationSans", str(lib_regular)))
            pdfmetrics.registerFont(TTFont("LiberationSans-Bold", str(lib_bold)))
            return "LiberationSans", "LiberationSans-Bold"
    return "Helvetica", "Helvetica-Bold"


FONT, FONT_BOLD = register_fonts()


def styles() -> dict[str, ParagraphStyle]:
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "SankhyaTitle",
            parent=base["Title"],
            fontName=FONT_BOLD,
            fontSize=16,
            leading=20,
            textColor=DARK_GREEN,
            alignment=TA_LEFT,
            spaceAfter=12,
            keepWithNext=True,
        ),
        "subtitle": ParagraphStyle(
            "SankhyaSubtitle",
            parent=base["Heading2"],
            fontName=FONT_BOLD,
            fontSize=14,
            leading=18,
            textColor=DARK_GREEN,
            spaceBefore=8,
            spaceAfter=8,
            keepWithNext=True,
        ),
        "h3": ParagraphStyle(
            "SankhyaH3",
            parent=base["Heading3"],
            fontName=FONT_BOLD,
            fontSize=12.5,
            leading=16,
            textColor=DARK_GREEN,
            spaceBefore=8,
            spaceAfter=6,
            keepWithNext=True,
        ),
        "body": ParagraphStyle(
            "SankhyaBody",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=12,
            leading=16,
            textColor=BODY,
            alignment=TA_JUSTIFY,
            spaceAfter=8,
        ),
        "body_first": ParagraphStyle(
            "SankhyaBodyFirstPage",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=12,
            leading=16,
            textColor=BODY,
            alignment=TA_LEFT,
            spaceAfter=8,
        ),
        "bullet": ParagraphStyle(
            "SankhyaBullet",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=12,
            leading=16,
            leftIndent=14,
            firstLineIndent=0,
            textColor=BODY,
            alignment=TA_JUSTIFY,
            spaceAfter=4,
        ),
        "bullet_first": ParagraphStyle(
            "SankhyaBulletFirstPage",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=12,
            leading=16,
            leftIndent=14,
            firstLineIndent=0,
            textColor=BODY,
            alignment=TA_LEFT,
            spaceAfter=4,
        ),
        "caption": ParagraphStyle(
            "SankhyaCaption",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=9,
            leading=12,
            textColor=MUTED,
        ),
        "table_header": ParagraphStyle(
            "SankhyaTableHeader",
            parent=base["BodyText"],
            fontName=FONT_BOLD,
            fontSize=10.5,
            leading=13,
            textColor=colors.white,
        ),
        "table_cell": ParagraphStyle(
            "SankhyaTableCell",
            parent=base["BodyText"],
            fontName=FONT,
            fontSize=10.5,
            leading=13,
            textColor=BODY,
        ),
    }


def inline_markdown(text: str) -> str:
    escaped = html.escape(text.strip())
    escaped = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", escaped)
    escaped = re.sub(r"\*(.+?)\*", r"<i>\1</i>", escaped)
    escaped = re.sub(
        r"\[([^\]]+)\]\(([^)]+)\)",
        r'<link href="\2" color="#0066CC"><u>\1</u></link>',
        escaped,
    )
    return escaped


SECTION_HEADINGS = {
    "Objetivo",
    "Cenario Atual",
    "Cenário Atual",
    "Estrutura Tecnologica",
    "Estrutura Tecnológica",
    "Consideracoes sobre o Processo Produtivo",
    "Considerações sobre o Processo Produtivo",
    "Oportunidade",
    "Oportunidades",
    "Oportunidades de Evolucao",
    "Oportunidades de Evolução",
    "Consideracoes Finais",
    "Considerações Finais",
    "Absorcao direta",
    "Absorção direta",
    "Absorcao indireta",
    "Absorção indireta",
    "Estimativas preliminares:",
    "Estratégia de Implementação",
    "Estrategia de Implementacao",
    "Absorção direta dos custos",
    "Absorcao direta dos custos",
    "Absorção indireta dos custos",
    "Absorcao indireta dos custos",
}


def normalize_input(text: str) -> str:
    """Turn pasted prose into the light Markdown structure used by the generator."""
    lines = [line.rstrip() for line in text.splitlines()]
    has_explicit_markdown_title = any(line.strip().startswith("# ") for line in lines)
    nonempty_seen = 0
    normalized: list[str] = []

    for raw in lines:
        stripped = raw.strip()

        if stripped in {"⸻", "---"}:
            normalized.append("---" if stripped == "---" and has_explicit_markdown_title else "")
            continue

        if not stripped:
            normalized.append("")
            continue

        if stripped.startswith(("# ", "## ", "### ", "- ")):
            normalized.append(stripped)
            continue

        if stripped.startswith("* "):
            normalized.append("- " + stripped[2:])
            continue

        nonempty_seen += 1
        if not has_explicit_markdown_title and nonempty_seen == 1:
            normalized.append("# " + stripped)
            continue
        if not has_explicit_markdown_title and nonempty_seen == 2:
            normalized.append("## " + stripped)
            continue

        if re.match(r"^\d+\.\s+\S", stripped):
            normalized.append("## " + stripped)
            continue

        if stripped in SECTION_HEADINGS:
            h3_headings = {
                "Cenário Atual",
                "Cenario Atual",
                "Oportunidade",
                "Oportunidades",
                "Absorção direta dos custos",
                "Absorcao direta dos custos",
                "Absorção indireta dos custos",
                "Absorcao indireta dos custos",
            }
            marker = "###" if stripped in h3_headings else "##"
            normalized.append(f"{marker} {stripped}")
            continue

        normalized.append(stripped)

    return "\n".join(normalized)


def build_story(markdown_text: str):
    markdown_text = normalize_input(markdown_text)
    st = styles()
    story = []
    paragraph_lines: list[str] = []
    bullet_lines: list[str] = []
    table_lines: list[str] = []
    last_was_heading = False
    first_page_complete = False
    cover_mode = True
    cover_title_seen = False
    cover_blocks = 0

    def body_style_key() -> str:
        return "body" if first_page_complete else "body_first"

    def bullet_style_key() -> str:
        return "bullet" if first_page_complete else "bullet_first"

    def flush_paragraph():
        nonlocal last_was_heading, cover_blocks
        if paragraph_lines:
            text = " ".join(line.strip() for line in paragraph_lines)
            story.append(Paragraph(inline_markdown(text), st[body_style_key()]))
            if cover_mode and cover_title_seen:
                cover_blocks += 1
            paragraph_lines.clear()
            last_was_heading = False

    def flush_bullets():
        nonlocal last_was_heading
        if bullet_lines:
            items = [
                ListItem(
                    Paragraph(inline_markdown(item), st[bullet_style_key()]),
                    leftIndent=0,
                )
                for item in bullet_lines
            ]
            story.append(
                ListFlowable(
                    items,
                    bulletType="bullet",
                    start="circle",
                    leftIndent=16,
                    bulletFontName=FONT,
                    bulletFontSize=9,
                )
            )
            story.append(Spacer(1, 4))
            bullet_lines.clear()
            last_was_heading = False

    def flush_table():
        nonlocal last_was_heading
        if not table_lines:
            return

        rows: list[list[str]] = []
        for line in table_lines:
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if cells and all(re.fullmatch(r":?-{3,}:?", cell or "") for cell in cells):
                continue
            if cells:
                rows.append(cells)

        table_lines.clear()
        if not rows:
            return

        col_count = max(len(row) for row in rows)
        for row in rows:
            row.extend([""] * (col_count - len(row)))

        # Internal pages use the full readable width.  The first page keeps the
        # narrower institutional white column, while later pages have no green
        # side panel and therefore must not constrain tables to a narrow strip.
        frame_width = 17.0 * cm if first_page_complete else PAGE_W - 4.0 * cm
        header = [c.strip().lower() for c in rows[0]]
        if header and header[0] in {"atividade", "etapa"} and col_count == 3:
            col_widths = [0.14 * frame_width, 0.30 * frame_width, 0.56 * frame_width]
        elif header and header[0] == "card" and col_count == 4:
            col_widths = [0.08 * frame_width, 0.27 * frame_width, 0.20 * frame_width, 0.45 * frame_width]
        else:
            col_widths = [frame_width / col_count] * col_count
        data = []
        for row_idx, row in enumerate(rows):
            style_key = "table_header" if row_idx == 0 else "table_cell"
            data.append([Paragraph(inline_markdown(cell), st[style_key]) for cell in row])

        table = Table(data, colWidths=col_widths, hAlign="LEFT", repeatRows=1)
        table.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, 0), DARK_GREEN),
                    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                    ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#F5F8F6")),
                    ("GRID", (0, 0), (-1, -1), 0.45, colors.HexColor("#B7C9BD")),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 7),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 7),
                    ("TOPPADDING", (0, 0), (-1, -1), 6),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
                ]
            )
        )
        story.append(table)
        story.append(Spacer(1, 10))
        last_was_heading = False

    for raw in markdown_text.splitlines():
        line = raw.rstrip()
        stripped = line.strip()

        if not stripped:
            flush_table()
            flush_paragraph()
            flush_bullets()
            if cover_mode and cover_title_seen and cover_blocks >= 4 and not first_page_complete:
                story.append(PageBreak())
                first_page_complete = True
                cover_mode = False
                last_was_heading = False
            elif not last_was_heading:
                story.append(Spacer(1, 4))
            continue

        if stripped == "---":
            flush_table()
            flush_paragraph()
            flush_bullets()
            story.append(PageBreak())
            first_page_complete = True
            last_was_heading = False
            continue

        if stripped.startswith("|"):
            flush_paragraph()
            flush_bullets()
            table_lines.append(stripped)
            continue

        if stripped.startswith("# "):
            flush_table()
            flush_paragraph()
            flush_bullets()
            story.append(Paragraph(inline_markdown(stripped[2:]), st["title"]))
            cover_title_seen = True
            last_was_heading = True
            continue

        if stripped.startswith("## "):
            flush_table()
            flush_paragraph()
            flush_bullets()
            heading_text = stripped[3:].strip()
            if not first_page_complete and heading_text in {"Cenario Atual", "Cenário Atual"}:
                story.append(PageBreak())
                first_page_complete = True
                last_was_heading = False
            story.append(Paragraph(inline_markdown(stripped[3:]), st["subtitle"]))
            last_was_heading = True
            continue

        if stripped.startswith("### "):
            flush_table()
            flush_paragraph()
            flush_bullets()
            story.append(Paragraph(inline_markdown(stripped[4:]), st["h3"]))
            last_was_heading = True
            continue

        if stripped.startswith("- ") or stripped.startswith("* "):
            flush_table()
            flush_paragraph()
            bullet_lines.append(stripped[2:].strip())
            continue

        # Plain-text delivery reports keep rollback entries and invalid object
        # names on separate physical lines. Preserve those boundaries instead
        # of joining the whole block into one justified paragraph.
        if re.match(r"^\d{1,2}:\s+", stripped) or re.fullmatch(
            r"[A-Z][A-Z0-9_]{3,}", stripped
        ):
            flush_table()
            flush_paragraph()
            flush_bullets()
            story.append(Paragraph(inline_markdown(stripped), st[body_style_key()]))
            story.append(Spacer(1, 2))
            continue

        flush_table()
        flush_bullets()
        paragraph_lines.append(stripped)

    flush_table()
    flush_paragraph()
    flush_bullets()
    return story


def draw_common_footer(canvas, doc):
    canvas.saveState()
    canvas.drawImage(
        str(FOOTER_STRIP),
        0,
        0,
        width=PAGE_W,
        height=1.55 * cm,
        preserveAspectRatio=False,
        mask="auto",
    )
    canvas.setFont(FONT, 8)
    canvas.setFillColor(MUTED)
    canvas.drawRightString(PAGE_W - 1.6 * cm, 0.85 * cm, f"Página {doc.page}")
    canvas.restoreState()


def first_page(canvas, doc):
    canvas.saveState()
    canvas.drawImage(
        str(FIRST_PAGE_BG),
        0,
        0,
        width=PAGE_W,
        height=PAGE_H,
        preserveAspectRatio=False,
    )
    canvas.restoreState()
    draw_common_footer(canvas, doc)


def later_page(canvas, doc):
    canvas.saveState()
    canvas.drawImage(
        str(LOGO),
        1.55 * cm,
        PAGE_H - 2.25 * cm,
        width=4.25 * cm,
        height=1.1 * cm,
        preserveAspectRatio=True,
        mask="auto",
    )
    canvas.setStrokeColor(SANKHYA_GREEN)
    canvas.setLineWidth(1.4)
    canvas.line(1.55 * cm, PAGE_H - 2.55 * cm, PAGE_W - 1.55 * cm, PAGE_H - 2.55 * cm)
    canvas.restoreState()
    draw_common_footer(canvas, doc)


def generate(markdown_path: Path, output_path: Path):
    text = markdown_path.read_text(encoding="utf-8")
    doc = BaseDocTemplate(
        str(output_path),
        pagesize=A4,
        title=markdown_path.stem,
        author="Sankhya",
    )
    first_frame = Frame(
        13.0 * cm,
        3.1 * cm,
        PAGE_W - 14.5 * cm,
        PAGE_H - 8.8 * cm,
        leftPadding=0,
        rightPadding=0,
        topPadding=0,
        bottomPadding=0,
        id="first_page_white_area",
    )
    body_frame = Frame(
        2.0 * cm,
        2.4 * cm,
        PAGE_W - 4.0 * cm,
        PAGE_H - 5.8 * cm,
        leftPadding=0,
        rightPadding=0,
        topPadding=0,
        bottomPadding=0,
        id="body",
    )
    doc.addPageTemplates(
        [
            PageTemplate(id="First", frames=[first_frame], onPage=first_page),
            PageTemplate(id="Later", frames=[body_frame], onPage=later_page),
        ]
    )
    story = build_story(text)
    doc.pageTemplates[0].autoNextPageTemplate = "Later"
    doc.build(story)


def main():
    parser = argparse.ArgumentParser(
        description="Gera um PDF no padrao de papel timbrado Sankhya."
    )
    parser.add_argument("entrada", type=Path, help="Arquivo .md ou .txt com o conteudo.")
    parser.add_argument(
        "-o",
        "--saida",
        type=Path,
        default=ROOT / "saida-sankhya.pdf",
        help="Caminho do PDF gerado.",
    )
    args = parser.parse_args()
    generate(args.entrada, args.saida)
    print(args.saida)


if __name__ == "__main__":
    main()
