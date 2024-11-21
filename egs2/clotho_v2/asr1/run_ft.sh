#!/usr/bin/env bash
set -euo pipefail
# Runs fine-tuning

wandb_init_args=""
other_args="$@"

expdir=/compute/babel-13-33/sbharad2/expdir
dumpdir=/compute/babel-13-33/sbharad2/dumpdir

pt_tag=scratch_bart.splen30s.lr2e-4.lossnormT.20241120.113058

ckpt_name=valid.acc.ave
ckpt_name=10epoch

pre_trained_model_path=${expdir}/asr_pt.${pt_tag}/${ckpt_name}.pth
ft_tag=${pt_tag}.match_contest.${ckpt_name}
asr_speech_fold_length=4800 # 480000/16000 = 30 seconds

./asr.sh \
    --asr_tag ft.${ft_tag} \
    --expdir ${expdir} \
    --dumpdir ${dumpdir} \
    --feats_normalize uttmvn \
    --stage 11 \
    --asr_speech_fold_length ${asr_speech_fold_length} \
    --stop_stage 13 \
    --asr_stats_dir ${expdir}/asr_stats_finetune \
    --ngpu 2 \
    --gpu_inference true \
    --nj 8 \
    --inference_nj 1 \
    --max_wav_duration 30 \
    --token_type hugging_face \
    --use_lm false \
    --hugging_face_model_name_or_path "facebook/bart-base" \
    --inference_args "--beam_size 10 --ctc_weight 0.0 --hugging_face_decoder True" \
    --train_set development_clotho \
    --valid_set validation \
    --test_sets "evaluation" \
    --asr_config conf/beats_bart_ft.yaml \
    --pretrained_model ${pre_trained_model_path} \
    --inference_asr_model valid.acc.ave_5best.pth \
    --asr_args "${wandb_init_args} ${other_args}" \
    --local_score_opts ${expdir}/asr_ft.${ft_tag}/inference_beam_size10_ctc_weight0.0_hugging_face_decoderTrue_asr_model_${ckpt_name}
